require "test_helper"

class PhotoDwellEventsControllerTest < ActionDispatch::IntegrationTest
  test "index requires a signed-in superuser" do
    get photo_dwell_events_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get photo_dwell_events_path
    assert_redirected_to root_path
  end

  test "destroy requires a signed-in superuser" do
    photo = create_photo!
    photo.record_dwell!( 10 )
    event = photo.dwell_events.last

    delete photo_dwell_event_path( event )
    assert_redirected_to new_session_path( token: login_token )
  end

  test "destroy removes the event and hands its own seconds back out of the photo's running total" do
    sign_in_as( users( :one ) )
    photo = create_photo!
    photo.record_dwell!( 10 )
    photo.record_dwell!( 4 )
    event = photo.dwell_events.first

    assert_difference "PhotoDwellEvent.count", -1 do
      delete photo_dwell_event_path( event )
    end

    assert_equal 4, photo.reload.dwell_seconds.to_f
  end

  private
    def create_photo!( fixture_filename = "sample.jpg" )
      album = Album.create!( title: "Test Album" )
      photo = album.photos.create!( position: 1 )
      photo.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: fixture_filename, content_type: "image/jpeg" )
      photo
    end
end

#	photo_dwell_events_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
