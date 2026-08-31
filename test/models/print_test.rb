require "test_helper"

class PrintTest < ActiveSupport::TestCase
  test "a print can exist without a photograph at all — search indexes it by title alone" do
    print = Print.create!( title: "Untitled" )
    assert_not print.image.attached?
  end

  test "published? is true only once published_at has arrived" do
    print = create_print!( "sample.jpg" )
    assert_not print.published?

    print.update!( published_at: 1.day.from_now )
    assert_not print.published?

    print.update!( published_at: 1.day.ago )
    assert print.published?
  end

  test "the published and draft scopes split prints by that same published_at" do
    draft = create_print!( "sample.jpg" )
    published = create_print!( "sample.jpg" )
    published.update!( published_at: 1.day.ago )

    assert_includes Print.published, published
    assert_not_includes Print.published, draft
    assert_includes Print.draft, draft
    assert_not_includes Print.draft, published
  end

  test "exif reads every field off the image's own EXIF" do
    print = create_print!( "sample_full_exif.jpg" )

    exif = print.exif

    assert_equal Time.zone.parse( "2024-05-10 09:15:00 +0200" ), exif[ :original_date ]
    assert_equal "Canon EOS R5", exif[ :camera ]
    assert_equal "RF 24-70mm F2.8", exif[ :lens ]
    lat, lng = exif[ :gps ].split( ", " ).map( &:to_f )
    assert_in_delta 48.8566, lat, 0.001
    assert_in_delta 2.3522, lng, 0.001
  end

  test "exif is empty when there's nothing to read" do
    print = create_print!( "sample.jpg" )

    assert_equal( {}, print.exif )
  end

  test "a JPEG is shown as it is, and a HEIC as the JPEG made of it, the original left just as it came" do
    skip "ImageMagick can't read a HEIC on this machine" unless heic_readable?
    jpeg = create_print!( "sample.jpg" )
    heic = create_print!( "sample_full_exif.heic", content_type: "image/heic" )

    assert_equal jpeg.image.blob, jpeg.web_image.blob
    shown = heic.web_image.processed.image.blob

    assert_equal "image/jpeg", shown.content_type
    assert_equal "image/heic", heic.image.blob.content_type
    assert_equal File.binread( file_fixture( "sample_full_exif.heic" ) ), heic.image.download
  end

  test "exif reads a HEIC through the JPEG made of it, and gets what the JPEG itself carries" do
    skip "ImageMagick can't read a HEIC on this machine" unless heic_readable?
    print = create_print!( "sample_full_exif.heic", content_type: "image/heic" )

    exif = print.exif

    assert_equal Time.zone.parse( "2024-05-10 09:15:00 +0200" ), exif[ :original_date ]
    assert_equal "Canon EOS R5", exif[ :camera ]
    assert_equal "RF 24-70mm F2.8", exif[ :lens ]
  end

  test "a RAW is shown as the JPEG made of the TIFF developed from it, and is the same RAW afterwards, byte for byte" do
    skip "ImageMagick can't read a TIFF on this machine" unless heic_readable?
    print = create_print!( "sample.jpg", filename: "IMG_0001.NEF", content_type: "image/x-raw-nikon", identify: false )
    sample = file_fixture( "sample.jpg" ).to_s
    stand_in = lambda do |raw_path|
      tiff = "#{ raw_path }.tiff"
      MiniMagick::Image.open( sample ).tap { |picture| picture.format( "tiff" ) }.write( tiff )
      tiff
    end

    replacing( RawDeveloper, :develop, stand_in ) do
      shown = print.web_image.processed.image.blob
      assert_equal "image/jpeg", shown.content_type
    end

    assert_equal "image/x-raw-nikon", print.image.blob.content_type
    assert_equal File.binread( file_fixture( "sample.jpg" ) ), print.image.download
  end

  test "exif reads a RAW from the RAW itself, since the picture developed from it carries nothing" do
    skip "exiftool isn't installed on this machine" unless system( "exiftool", "-ver", out: File::NULL, err: File::NULL )
    print = create_print!( "sample_full_exif.heic", filename: "IMG_0002.CR3", content_type: "image/x-canon-cr3", identify: false )

    exif = print.exif

    assert_equal Time.local( 2024, 5, 10, 9, 15, 0 ), exif[ :original_date ]
    assert_equal "Canon EOS R5", exif[ :camera ]
    assert_equal "RF 24-70mm F2.8", exif[ :lens ]
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

    def create_print!( fixture_filename, content_type: "image/jpeg", filename: fixture_filename, identify: true )
      print = Print.new( title: "Test Print" )
      print.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: filename, content_type: content_type, identify: identify )
      print.save!
      print
    end

    def heic_readable?
      require "mini_magick"
      MiniMagick::Image.open( file_fixture( "sample_full_exif.heic" ).to_s ).valid?
    rescue StandardError
      false
    end
end

#	print_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
