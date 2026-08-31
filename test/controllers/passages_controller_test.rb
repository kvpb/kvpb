require "test_helper"

class PassagesControllerTest < ActionDispatch::IntegrationTest
  test "writing a passage requires a signed-in superuser" do
    get new_passage_path( album )
    assert_redirected_to new_session_path( token: login_token )

    assert_no_difference "Passage.count" do
      post passages_path( album ), params: { passage: { position: 1, body: "Uninvited." } }
    end
  end

  test "create adds a passage to the album" do
    sign_in_as( users( :one ) )

    assert_difference "Passage.count", 1 do
      post passages_path( album ), params: { passage: { position: 2, heading: "6 February 2025", body: "We rolled out." } }
    end

    assert_redirected_to album_path( album )
    passage = album.passages.last
    assert_equal 2, passage.position
    assert_equal "6 February 2025", passage.heading
  end

  test "create refuses a passage carrying neither heading nor body" do
    sign_in_as( users( :one ) )

    assert_no_difference "Passage.count" do
      post passages_path( album ), params: { passage: { position: 1 } }
    end

    assert_response :unprocessable_entity
  end

  test "update rewrites a passage" do
    sign_in_as( users( :one ) )
    passage = album.passages.create!( position: 1, body: "First draft." )

    patch passage_path( album, passage ), params: { passage: { body: "Second draft." } }

    assert_equal "Second draft.", passage.reload.body
  end

  test "destroy removes a passage, and only for a signed-in superuser" do
    passage = album.passages.create!( position: 1, body: "Doomed." )

    assert_no_difference "Passage.count" do
      delete passage_path( album, passage )
    end

    sign_in_as( users( :one ) )
    assert_difference "Passage.count", -1 do
      delete passage_path( album, passage )
    end
  end

  private
    def album
      @album ||= Album.create!( title: "Test Album" )
    end
end

#	passages_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
