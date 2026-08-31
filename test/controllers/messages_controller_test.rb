require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "index requires a signed-in admin" do
    get messages_path
    assert_redirected_to root_path

    sign_in_as( users( :two ) )
    get messages_path
    assert_redirected_to root_path
  end

  test "index lists messages for a signed-in admin" do
    sign_in_as( users( :one ) )

    get messages_path

    assert_response :success
    assert_match messages( :unread_message ).name, response.body
    assert_match messages( :read_message ).name, response.body
  end

  test "mark_read requires a signed-in admin" do
    patch mark_read_message_path( messages( :unread_message ) )
    assert_redirected_to root_path
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

  test "the inbox lives under the back end, and its header says so by name, not just \"back end\"" do
    sign_in_as( users( :one ) )

    assert_equal "/backend/inbox", messages_path
    assert_equal "/messages", old_messages_path

    get messages_path
    assert_response :success
    assert_select "#section_header", text: /inbox/i
    assert_select "#section_header", text: /back end/i, count: 0

    get old_messages_path
    assert_response :success
  end

  test "keep and unkeep require a signed-in admin" do
    patch keep_message_path( messages( :unread_message ) )
    assert_redirected_to root_path
    assert_not messages( :unread_message ).reload.kept?

    messages( :unread_message ).update!( kept: true )
    patch unkeep_message_path( messages( :unread_message ) )
    assert_redirected_to root_path
    assert messages( :unread_message ).reload.kept?
  end

  test "keep tags a message to be kept, and unkeep lets it go again" do
    sign_in_as( users( :one ) )

    patch keep_message_path( messages( :unread_message ) )
    assert_redirected_to messages_path
    assert messages( :unread_message ).reload.kept?

    patch unkeep_message_path( messages( :unread_message ) )
    assert_not messages( :unread_message ).reload.kept?
  end

  test "index tells a kept message from a loose one and offers the opposite action" do
    sign_in_as( users( :one ) )
    messages( :unread_message ).update!( kept: true )

    get messages_path

    assert_select ".message_entry.kept", count: 1
    assert_select ".message_kept_tag", count: 1
    assert_select "form[action='#{ unkeep_message_path( messages( :unread_message ) ) }']"
    assert_select "form[action='#{ keep_message_path( messages( :read_message ) ) }']"
  end

  test "forward requires a signed-in admin" do
    assert_no_emails do
      post forward_message_path( messages( :unread_message ) )
    end
    assert_redirected_to root_path
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
