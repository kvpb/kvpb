require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the disabled view when registration is closed" do
    Setting.current.update!( registration_enabled: false )

    get new_registration_path

    assert_response :success
    assert_select "p", text: "Registration is currently closed."
  end

  test "new renders the sign-up form when registration is open" do
    Setting.current.update!( registration_enabled: true )

    get new_registration_path

    assert_response :success
    assert_select "form"
  end

  test "create does not build a user while registration is closed" do
    Setting.current.update!( registration_enabled: false )

    assert_no_difference( "User.count" ) do
      post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123" } }
    end
  end

  test "create builds a regular, non-superuser account while registration is open" do
    Setting.current.update!( registration_enabled: true )

    assert_difference( "User.count", 1 ) do
      post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123" } }
    end

    assert_not User.find_by!( username: "newbie" ).superuser?
    assert cookies[ :session_id ]
  end

  test "create ignores an injected superuser param" do
    Setting.current.update!( registration_enabled: true )

    post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123", superuser: true } }

    assert_not User.find_by!( username: "newbie" ).superuser?
  end
end

#	registrations_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
