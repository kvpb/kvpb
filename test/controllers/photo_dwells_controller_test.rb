require "test_helper"

class PhotoDwellsControllerTest < ActionDispatch::IntegrationTest
  test "create adds the reported seconds to the photo, anonymously" do
    photo = create_photo!

    post photo_dwell_path( photo ), params: { seconds: 4.2 }, as: :json

    assert_response :no_content
    assert_equal 4.2, photo.reload.dwell_seconds.to_f
  end

  test "create clamps an implausible value rather than trusting the visitor's own report" do
    photo = create_photo!

    post photo_dwell_path( photo ), params: { seconds: 100_000 }, as: :json

    assert_equal 300, photo.reload.dwell_seconds.to_f
  end

  test "index requires a signed-in superuser" do
    get photo_dwells_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get photo_dwells_path
    assert_redirected_to root_path
  end

  test "index lists photos ranked by dwell time, most attention-grabbing first" do
    sign_in_as( users( :one ) )
    create_photo!.record_dwell!( 3 )
    create_photo!.record_dwell!( 30 )

    get photo_dwells_path

    assert_response :success
    assert_operator response.body.index( "0m 30s" ), :<, response.body.index( "0m 03s" )
  end

  private
    def create_photo!( fixture_filename = "sample.jpg" )
      album = Album.create!( title: "Test Album" )
      photo = album.photos.create!( position: 1 )
      photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: fixture_filename, content_type: "image/jpeg" )
      photo
    end
end

#	photo_dwells_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
