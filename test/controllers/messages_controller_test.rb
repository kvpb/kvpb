require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "index requires a signed-in superuser" do
    get messages_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get messages_path
    assert_redirected_to root_path
  end

  test "index lists messages for a signed-in superuser" do
    sign_in_as( users( :one ) )

    get messages_path

    assert_response :success
    assert_match messages( :unread_message ).name, response.body
    assert_match messages( :read_message ).name, response.body
  end

  test "mark_read requires a signed-in superuser" do
    patch mark_read_message_path( messages( :unread_message ) )
    assert_redirected_to new_session_path( token: login_token )
  end

  test "mark_read marks a message as read" do
    sign_in_as( users( :one ) )

    patch mark_read_message_path( messages( :unread_message ) )

    assert messages( :unread_message ).reload.read?
  end

  test "mark_unread marks a message as unread" do
    sign_in_as( users( :one ) )

    patch mark_unread_message_path( messages( :read_message ) )

    assert_not messages( :read_message ).reload.read?
  end

  test "forward requires a signed-in superuser" do
    assert_no_emails do
      post forward_message_path( messages( :unread_message ) )
    end
    assert_redirected_to new_session_path( token: login_token )
  end

  test "forward emails the message and redirects with a notice" do
    sign_in_as( users( :one ) )

    assert_emails 1 do
      post forward_message_path( messages( :unread_message ) )
    end

    assert_redirected_to messages_path
  end
end

#	messages_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
