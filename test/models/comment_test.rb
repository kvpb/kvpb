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

class CommentTest < ActiveSupport::TestCase
  test "guest comment requires author_name and author_email" do
    comment = Comment.new( article: articles( :published ), body: "Hi" )
    assert_not comment.valid?
    assert_includes comment.errors.attribute_names, :author_name
    assert_includes comment.errors.attribute_names, :author_email
  end

  test "guest comment defaults to pending" do
    comment = Comment.create!( article: articles( :published ), author_name: "Guest", author_email: "guest@example.com", body: "Hi" )
    assert comment.pending?
  end

  test "user-authored comment does not require author_name or author_email and is auto-approved" do
    comment = Comment.create!( article: articles( :published ), user: users( :one ), body: "Hi" )
    assert comment.approved?
  end

  test "visible scope only includes approved comments" do
    assert_includes Comment.visible, comments( :approved_guest )
    assert_not_includes Comment.visible, comments( :pending_guest )
  end

  test "author_display_name prefers the account username for user-authored comments" do
    assert_equal users( :one ).username, comments( :user_authored ).author_display_name
    assert_equal "A visitor", comments( :pending_guest ).author_display_name
  end
end

#	comment_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
