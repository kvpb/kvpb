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

  private
    def create_photo!( fixture_filename )
      album = Album.create!( title: "Test Album" )
      photo = album.photos.create!( position: 1 )
      photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: fixture_filename, content_type: "image/jpeg" )
      photo
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
