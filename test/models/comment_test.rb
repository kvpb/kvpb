require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "guest comment requires author_name and author_email" do
    comment = Comment.new(article: articles(:published), body: "Hi")
    assert_not comment.valid?
    assert_includes comment.errors.attribute_names, :author_name
    assert_includes comment.errors.attribute_names, :author_email
  end

  test "guest comment defaults to pending" do
    comment = Comment.create!(article: articles(:published), author_name: "Guest", author_email: "guest@example.com", body: "Hi")
    assert comment.pending?
  end

  test "user-authored comment does not require author_name or author_email and is auto-approved" do
    comment = Comment.create!(article: articles(:published), user: users(:one), body: "Hi")
    assert comment.approved?
  end

  test "visible scope only includes approved comments" do
    assert_includes Comment.visible, comments(:approved_guest)
    assert_not_includes Comment.visible, comments(:pending_guest)
  end

  test "author_display_name prefers the account username for user-authored comments" do
    assert_equal users(:one).username, comments(:user_authored).author_display_name
    assert_equal "A visitor", comments(:pending_guest).author_display_name
  end
end
