require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "requires a name, phone number, email address, and body" do
    message = Message.new
    assert_not message.valid?
    assert_includes message.errors.attribute_names, :name
    assert_includes message.errors.attribute_names, :phone_number
    assert_includes message.errors.attribute_names, :email_address
    assert_includes message.errors.attribute_names, :body
  end

  test "rejects a malformed email address" do
    message = Message.new( name: "Guest", phone_number: "0123456789", email_address: "not-an-email", body: "Hello" )
    assert_not message.valid?
    assert_includes message.errors.attribute_names, :email_address
  end

  test "defaults to unread" do
    message = Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Hello" )
    assert_not message.read?
  end

  test "chronological orders the most recent message first" do
    ordered = Message.chronological
    assert_equal ordered.first.created_at, ordered.map( &:created_at ).max
  end
end

#	message_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
