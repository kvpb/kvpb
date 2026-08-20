require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  test "edit requires a signed-in superuser" do
    photo = create_photo!

    get edit_photo_path( photo.album, photo )
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get edit_photo_path( photo.album, photo )
    assert_redirected_to root_path
  end

  test "update overrides a field and stops it from being overwritten by the next refresh" do
    sign_in_as( users( :one ) )
    photo = create_photo!

    patch photo_path( photo.album, photo ), params: { photo: { author: "Someone Else" } }

    photo.reload
    assert_equal "Someone Else", photo.author
    assert photo.author_overridden?
  end

  test "update recomputes the album's own captured period" do
    sign_in_as( users( :one ) )
    photo = create_photo!( "sample_full_exif.jpg" )
    photo.refresh_from_exif!

    patch photo_path( photo.album, photo ), params: { photo: { author: "Someone Else" } }

    assert_equal Date.new( 2024, 5, 10 ), photo.album.reload.taken_from
  end

  test "destroy removes the photo and requires a signed-in superuser" do
    photo = create_photo!

    assert_no_difference( "Photo.count" ) do
      delete photo_path( photo.album, photo )
    end

    sign_in_as( users( :one ) )
    assert_difference( "Photo.count", -1 ) do
      delete photo_path( photo.album, photo )
    end
  end

  private
    def create_photo!( fixture_filename = "sample.jpg" )
      album = Album.create!( title: "Test Album" )
      photo = album.photos.create!( position: 1 )
      photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: fixture_filename, content_type: "image/jpeg" )
      photo
    end
end

#	photos_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
