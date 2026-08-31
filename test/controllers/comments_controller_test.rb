require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "guest comment is created pending and is not publicly visible" do
    article = articles( :published )

    assert_difference( "Comment.count", 1 ) do
      post article_comments_path( article ), params: { comment: { author_name: "Guest", author_email: "guest@example.com", body: "Hello" } }
    end

    comment = Comment.order( :created_at ).last
    assert comment.pending?

    get article_path( article )
    assert_no_match "Hello", response.body
  end

  test "honeypot field silently drops the comment" do
    article = articles( :published )

    assert_no_difference( "Comment.count" ) do
      post article_comments_path( article ), params: { comment: { author_name: "Bot", author_email: "bot@example.com", body: "Spam", website: "https://spam.example" } }
    end

    assert_redirected_to article_path( article )
  end

  test "comments are rejected when the article has comments locked" do
    article = articles( :locked )

    assert_no_difference( "Comment.count" ) do
      post article_comments_path( article ), params: { comment: { author_name: "Guest", author_email: "guest@example.com", body: "Hello" } }
    end
  end

  test "a signed-in user's comment is attributed to their account and auto-approved" do
    sign_in_as( users( :two ) )
    article = articles( :published )

    assert_difference( "Comment.count", 1 ) do
      post article_comments_path( article ), params: { comment: { body: "Hello from my account" } }
    end

    comment = Comment.order( :created_at ).last
    assert comment.approved?
    assert_equal users( :two ), comment.user
  end

  test "approve requires a signed-in superuser" do
    comment = comments( :pending_guest )
    article = comment.article

    patch approve_article_comment_path( article, comment )
    assert_redirected_to new_session_path( token: login_token )
    assert comment.reload.pending?
  end

  test "superuser can approve a pending comment" do
    sign_in_as( users( :one ) )
    comment = comments( :pending_guest )
    article = comment.article

    patch approve_article_comment_path( article, comment )

    assert comment.reload.approved?
  end

  test "superuser rejecting a comment deletes it and emails the author a copy" do
    sign_in_as( users( :one ) )
    comment = comments( :pending_guest )
    article = comment.article

    assert_emails 1 do
      assert_difference( "Comment.count", -1 ) do
        delete reject_article_comment_path( article, comment )
      end
    end

    assert_equal [ comment.author_email ], ActionMailer::Base.deliveries.last.to
  end
end

#	comments_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
