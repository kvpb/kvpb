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

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path( token: login_token )
    assert_response :success
  end

  test "new sets no-index headers" do
    get new_session_path( token: login_token )

    assert_equal "noindex, nofollow", response.headers[ "X-Robots-Tag" ]
    assert_equal "no-store", response.headers[ "Cache-Control" ]
    assert_match %r{<meta name="robots" content="noindex, nofollow">}, response.body
  end

  test "the wrong token 404s instead of reaching sign-in" do
    get "/not-the-real-token/new"
    assert_response :not_found
  end

  test "create with valid credentials" do
    post session_path( token: login_token ), params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[ :session_id ]
  end

  test "create with invalid credentials" do
    post session_path( token: login_token ), params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path( token: login_token )
    assert_nil cookies[ :session_id ]
  end

  test "destroy" do
    sign_in_as( User.take )

    delete session_path( token: login_token )

    assert_redirected_to root_path
    assert_empty cookies[ :session_id ]
  end
end

#	sessions_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
