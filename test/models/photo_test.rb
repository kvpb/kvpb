require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "refresh_from_exif! reads every field off the image's own EXIF" do
    photo = create_photo!( "sample_full_exif.jpg" )

    photo.refresh_from_exif!

    assert_equal Time.zone.parse( "2024-05-10 09:15:00 +0200" ), photo.taken_at
    assert_equal "Karl Bertin", photo.author
    assert_equal "Canon EOS R5", photo.camera
    assert_equal "RF 24-70mm F2.8", photo.lens
    assert_in_delta 48.8566, photo.latitude, 0.001
    assert_in_delta 2.3522, photo.longitude, 0.001
  end

  test "refresh_from_exif! leaves fields blank when there's nothing to read" do
    photo = create_photo!( "sample.jpg" )

    photo.refresh_from_exif!

    assert_nil photo.taken_at
    assert_nil photo.author
    assert_nil photo.camera
    assert_nil photo.lens
    assert_nil photo.latitude
  end

  test "refresh_from_exif! never touches a field that's been manually overridden" do
    photo = create_photo!( "sample_full_exif.jpg" )
    photo.update!( author: "Someone Else", author_overridden: true )

    photo.refresh_from_exif!

    assert_equal "Someone Else", photo.author
    assert_equal "Canon EOS R5", photo.camera
  end

  test "apply_manual_fields! stores a submitted value and flags it overridden" do
    photo = create_photo!( "sample.jpg" )

    photo.apply_manual_fields!( author: "Someone Else" )

    assert_equal "Someone Else", photo.author
    assert photo.author_overridden?
  end

  test "apply_manual_fields! clears the override and re-reads EXIF when a field is submitted blank" do
    photo = create_photo!( "sample_full_exif.jpg" )
    photo.apply_manual_fields!( camera: "A Different Camera" )
    assert photo.camera_overridden?

    photo.apply_manual_fields!( camera: "" )

    assert_not photo.camera_overridden?
    assert_equal "Canon EOS R5", photo.camera
  end

  test "refresh_from_exif! enqueues geocoding once, only when GPS is present and place isn't overridden" do
    photo = create_photo!( "sample_full_exif.jpg" )

    assert_enqueued_with( job: PhotoGeocodeJob, args: [ photo.id ] ) do
      photo.refresh_from_exif!
    end
  end

  test "refresh_from_exif! doesn't enqueue geocoding once place has been manually overridden" do
    photo = create_photo!( "sample_full_exif.jpg" )
    photo.update!( place: "Somewhere Else", place_overridden: true )

    assert_no_enqueued_jobs( only: PhotoGeocodeJob ) do
      photo.refresh_from_exif!
    end
  end

  test "record_dwell! adds the given seconds to the running total" do
    photo = create_photo!( "sample.jpg" )

    photo.record_dwell!( 4.5 )
    photo.record_dwell!( 2 )

    assert_equal 6.5, photo.reload.dwell_seconds.to_f
  end

  test "record_dwell! logs its own clamped seconds as an anonymous event" do
    photo = create_photo!( "sample.jpg" )

    photo.record_dwell!( 100_000 )

    assert_equal 1, photo.dwell_events.count
    assert_equal 300, photo.dwell_events.last.seconds.to_f
  end

  test "record_dwell! clamps a negative value to zero" do
    photo = create_photo!( "sample.jpg" )

    photo.record_dwell!( -10 )

    assert_equal 0, photo.reload.dwell_seconds.to_f
  end

  test "record_dwell! clamps an implausibly large value" do
    photo = create_photo!( "sample.jpg" )

    photo.record_dwell!( 100_000 )

    assert_equal 300, photo.reload.dwell_seconds.to_f
  end

  test "a JPEG is shown as it is, and a HEIC as the JPEG made of it, the original left just as it came" do
    skip "ImageMagick can't read a HEIC on this machine" unless heic_readable?
    jpeg = create_photo!( "sample.jpg" )
    heic = create_photo!( "sample_full_exif.heic", content_type: "image/heic" )

    assert_equal jpeg.image.blob, jpeg.web_image.blob
    shown = heic.web_image.processed.image.blob

    assert_equal "image/jpeg", shown.content_type
    assert_equal "image/heic", heic.image.blob.content_type
    assert_equal "sample_full_exif.heic", heic.image.filename.to_s
    assert_equal File.binread( file_fixture( "sample_full_exif.heic" ) ), heic.image.download
  end

  test "refresh_from_exif! reads a HEIC through the JPEG made of it, and gets what the JPEG itself carries" do
    skip "ImageMagick can't read a HEIC on this machine" unless heic_readable?
    photo = create_photo!( "sample_full_exif.heic", content_type: "image/heic" )

    photo.refresh_from_exif!

    assert_equal Time.zone.parse( "2024-05-10 09:15:00 +0200" ), photo.taken_at
    assert_equal "Karl Bertin", photo.author
    assert_equal "Canon EOS R5", photo.camera
    assert_equal "RF 24-70mm F2.8", photo.lens
  end

  test "a RAW is shown as the JPEG made of the TIFF developed from it, and is the same RAW afterwards, byte for byte" do
    skip "ImageMagick can't read a TIFF on this machine" unless heic_readable?
    photo = create_photo!( "sample.jpg", filename: "IMG_0001.NEF", content_type: "image/x-raw-nikon", identify: false )
    developed = []
    sample = file_fixture( "sample.jpg" ).to_s
    stand_in = lambda do |raw_path|
      developed << raw_path
      tiff = "#{ raw_path }.tiff"
      MiniMagick::Image.open( sample ).tap { |picture| picture.format( "tiff" ) }.write( tiff )
      tiff
    end

    replacing( RawDeveloper, :develop, stand_in ) do
      assert photo.image.variable?
      shown = photo.web_image.processed.image.blob

      assert_equal "image/jpeg", shown.content_type
    end

    assert_equal 1, developed.size
    assert_match( /\.NEF\z/i, developed.first )
    assert_equal "image/x-raw-nikon", photo.image.blob.content_type
    assert_equal File.binread( file_fixture( "sample.jpg" ) ), photo.image.download
  end

  test "refresh_from_exif! reads a RAW from the RAW itself, since the picture developed from it carries nothing" do
    skip "exiftool isn't installed on this machine" unless system( "exiftool", "-ver", out: File::NULL, err: File::NULL )
    photo = create_photo!( "sample_full_exif.heic", filename: "IMG_0002.CR3", content_type: "image/x-canon-cr3", identify: false )

    photo.refresh_from_exif!

    assert_equal Time.local( 2024, 5, 10, 9, 15, 0 ), photo.taken_at
    assert_equal "Canon EOS R5", photo.camera
    assert_equal "RF 24-70mm F2.8", photo.lens
    assert_equal "Karl Bertin", photo.author
  end

  private
    # minitest 6 no longer ships stub: an object's method is swapped for the length of the block, then put back
    def replacing( object, name, with )
      original = object.method( name )
      object.define_singleton_method( name, &with )
      yield
    ensure
      object.define_singleton_method( name, original )
    end

    def create_photo!( fixture_filename, content_type: "image/jpeg", filename: fixture_filename, identify: true )
      album = Album.create!( title: "Test Album" )
      photo = album.photos.create!( position: 1 )
      photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: filename, content_type: content_type, identify: identify )
      photo
    end
    # def create_photo!( fixture_filename )
    #   album = Album.create!( title: "Test Album" )
    #   photo = album.photos.create!( position: 1 )
    #   photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: fixture_filename, content_type: "image/jpeg" )
    #   photo
    # end

    def heic_readable?
      require "mini_magick"
      MiniMagick::Image.open( file_fixture( "sample_full_exif.heic" ).to_s ).valid?
    rescue StandardError
      false
    end
end

#	photo_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
