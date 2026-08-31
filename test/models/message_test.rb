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

  test "no field may exceed its ceiling" do
    valid = { name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Hello" }

    assert Message.new( valid ).valid?
    assert Message.new( valid.merge( name: "a" * Message::MAX_NAME ) ).valid?
    assert Message.new( valid.merge( body: "a" * Message::MAX_BODY ) ).valid?

    assert_not Message.new( valid.merge( name: "a" * ( Message::MAX_NAME + 1 ) ) ).valid?
    assert_not Message.new( valid.merge( phone_number: "1" * ( Message::MAX_PHONE_NUMBER + 1 ) ) ).valid?
    assert_not Message.new( valid.merge( email_address: "#{ "a" * Message::MAX_EMAIL_ADDRESS }@example.com" ) ).valid?
    assert_not Message.new( valid.merge( body: "a" * ( Message::MAX_BODY + 1 ) ) ).valid?
  end

  test "only the latest hundred messages are kept, the oldest going first" do
    Message.delete_all
    start = Time.zone.parse( "2026-09-01 10:00" )

    ( Message::KEPT + 1 ).times do |i|
      Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Message #{ i }", created_at: start + i.minutes )
    end

    assert_equal Message::KEPT, Message.count
    assert_not Message.exists?( body: "Message 0" )
    assert Message.exists?( body: "Message 1" )
    assert Message.exists?( body: "Message #{ Message::KEPT }" )
  end

  test "a message tagged to keep is never pushed out, and does not count among the hundred" do
    Message.delete_all
    start = Time.zone.parse( "2026-09-01 10:00" )
    saved = Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Worth saving", created_at: start, kept: true )

    Message::KEPT.times do |i|
      Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Message #{ i }", created_at: start + ( i + 1 ).minutes )
    end
    assert_equal Message::KEPT + 1, Message.count
    assert Message.exists?( id: saved.id )

    Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "One too many", created_at: start + 1.day )

    assert Message.exists?( id: saved.id ), "the message tagged to keep is still there"
    assert_not Message.exists?( body: "Message 0" ), "the oldest loose message went instead"
    assert_equal Message::KEPT + 1, Message.count
  end

  test "defaults to not kept" do
    message = Message.create!( name: "Guest", phone_number: "0123456789", email_address: "guest@example.com", body: "Hello" )
    assert_not message.kept?
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
