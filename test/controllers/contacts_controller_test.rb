require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "a valid message is stored in the back end and no email is sent" do
    assert_difference "Message.count", 1 do
      assert_no_emails do
        post contact_path, params: { message: { name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Hello" } }
      end
    end

    assert_redirected_to gettoknowandcontact_path
    assert flash[ :message_sent ]
  end

  test "an invalid message is not stored" do
    assert_no_difference "Message.count" do
      post contact_path, params: { message: { name: "", phone_number: "", email_address: "not-an-email", body: "" } }
    end
  end

  test "a message without a phone number is not stored" do
    assert_no_difference "Message.count" do
      post contact_path, params: { message: { name: "Guest", phone_number: "", email_address: "guest@example.com", body: "Hello" } }
    end
  end

  test "honeypot field silently drops the message" do
    assert_no_difference "Message.count" do
      post contact_path, params: { message: { name: "Bot", phone_number: "0123456789", email_address: "bot@example.com", body: "Spam", website: "https://spam.example" } }
    end

    assert_redirected_to gettoknowandcontact_path
    assert flash[ :message_sent ]
  end
end

#	contacts_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
