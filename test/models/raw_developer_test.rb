require "test_helper"

class RawDeveloperTest < ActiveSupport::TestCase
  test "a RAW is known by its extension, whatever its case, and a JPEG, a HEIC or a TIFF is not" do
    %w[ IMG_1.NEF IMG_2.cr3 IMG_3.Dng IMG_4.ARW IMG_5.raf ].each { |name| assert RawDeveloper.raw?( name ), name }
    %w[ IMG_1.JPG IMG_2.heic IMG_3.tiff IMG_4.png noextension ].each { |name| assert_not RawDeveloper.raw?( name ), name }
  end

  test "exiftool gives what EXIFR gives for a JPEG: the date, the artist, the camera and the lens" do
    skip "exiftool isn't installed on this machine" unless exiftool?

    data = RawDeveloper.exif( file_fixture( "sample_full_exif.heic" ) )

    assert_equal Time.local( 2024, 5, 10, 9, 15, 0 ), data.date_time_original
    assert_equal "Karl Bertin", data.artist
    assert_equal "Canon", data.make
    assert_equal "EOS R5", data.model
    assert_equal "RF 24-70mm F2.8", data.lens_model
  end

  test "a file with nothing readable in it gives nothing, not an error" do
    assert_nil RawDeveloper.exif( file_fixture( "sample.jpg" ).dirname.join( "not_there.nef" ) ) if exiftool?
  end

  test "when dcraw_emu isn't there the error says so, rather than a bare failure to find a file" do
    replacing( Open3, :capture3, ->( *_args ) { raise Errno::ENOENT } ) do
      error = assert_raises( RawDeveloper::Error ) { RawDeveloper.develop( "/tmp/IMG_1.NEF" ) }
      assert_match "libraw-bin", error.message
    end
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

    def exiftool?
      system( "exiftool", "-ver", out: File::NULL, err: File::NULL )
    end
end

#	raw_developer_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
