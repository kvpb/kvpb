#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its
#	documentation for any purpose and without fee is hereby granted, provided that
#	the above copyright notice appear in all copies and that both that copyright
#	notice and this permission notice appear in supporting documentation, and that
#	the name of Karl Vincent Pierre Bertin not be used in advertising or publicity
#	pertaining to distribution of the software without specific, written prior
#	permission. Karl Vincent Pierre Bertin makes no representations about the
#	suitability of this software for any purpose.  It is provided "as is" without
#	express or implied warranty.

require "test_helper"

class HonoreesControllerTest < ActionDispatch::IntegrationTest
  test "index lists only published honorees for guests" do
    get hall_of_fame_path

    assert_response :success
    assert_match honorees( :published_human ).name, response.body
    assert_no_match honorees( :draft_animal ).name, response.body
  end

  test "index lists drafts too for a signed-in superuser" do
    sign_in_as( users( :one ) )

    get hall_of_fame_path

    assert_match honorees( :draft_animal ).name, response.body
  end

  test "show renders a published honoree for guests" do
    get honoree_path( honorees( :published_human ) )

    assert_response :success
  end

  test "show 404s a draft for guests" do
    get honoree_path( honorees( :draft_animal ) )

    assert_response :not_found
  end

  test "new requires a signed-in superuser" do
    get new_honoree_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get new_honoree_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in superuser" do
    assert_no_difference( "Honoree.count" ) do
      post hall_of_fame_path, params: { honoree: { name: "Someone", body: "Body" } }
    end
  end

  test "create builds a draft honoree by default" do
    sign_in_as( users( :one ) )

    assert_difference( "Honoree.count", 1 ) do
      post hall_of_fame_path, params: { honoree: { name: "New Honoree", body: "Body" } }
    end

    assert_not Honoree.find_by!( identifier: "new-honoree" ).published?
  end

  test "update lets a superuser publish" do
    sign_in_as( users( :one ) )
    honoree = honorees( :draft_animal )

    patch honoree_path( honoree ), params: { honoree: { published_at: Time.current } }

    assert honoree.reload.published?
  end

  test "destroy requires a signed-in superuser" do
    assert_no_difference( "Honoree.count" ) do
      delete honoree_path( honorees( :published_human ) )
    end
  end

  test "autosave create responds with json and switches the record to update mode" do
    sign_in_as( users( :one ) )

    assert_difference( "Honoree.count", 1 ) do
      post hall_of_fame_path( format: :json ), params: { honoree: { name: "Autosaved draft" } }
    end

    assert_response :success
    body = JSON.parse( response.body )
    honoree = Honoree.find_by!( identifier: "autosaved-draft" )
    assert body[ "ok" ]
    assert_equal edit_honoree_path( honoree ), body[ "edit_url" ]
    assert_not honoree.published?
  end

  test "autosave update responds with json" do
    sign_in_as( users( :one ) )
    honoree = honorees( :draft_animal )

    patch honoree_path( honoree, format: :json ), params: { honoree: { honor_inscription: "Updated via autosave" } }

    assert_response :success
    assert JSON.parse( response.body )[ "ok" ]
    assert_equal "Updated via autosave", honoree.reload.honor_inscription
  end
end

#	honorees_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
