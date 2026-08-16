require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index lists only published articles for guests" do
    get read_path

    assert_response :success
    assert_match articles(:published).headline, response.body
    assert_no_match articles(:draft).headline, response.body
  end

  test "index lists drafts too for a signed-in superuser" do
    sign_in_as(users(:one))

    get read_path

    assert_match articles(:draft).headline, response.body
  end

  test "show renders a published article for guests" do
    get article_path(articles(:published))

    assert_response :success
  end

  test "show 404s a draft for guests" do
    get article_path(articles(:draft))

    assert_response :not_found
  end

  test "show renders a draft for a signed-in superuser" do
    sign_in_as(users(:one))

    get article_path(articles(:draft))

    assert_response :success
  end

  test "new requires a signed-in superuser" do
    get new_article_path
    assert_redirected_to new_session_path

    sign_in_as(users(:two))
    get new_article_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in superuser" do
    assert_no_difference("Article.count") do
      post read_path, params: { article: { headline: "Hello", body: "Body" } }
    end
  end

  test "create builds an article as a draft by default" do
    sign_in_as(users(:one))

    assert_difference("Article.count", 1) do
      post read_path, params: { article: { headline: "Hello World", body: "Body" } }
    end

    assert_not Article.find_by!(identifier: "hello-world").published?
  end

  test "update lets a superuser publish and lock comments" do
    sign_in_as(users(:one))
    article = articles(:draft)

    patch article_path(article), params: { article: { published_at: Time.current, comments_locked: true } }

    article.reload
    assert article.published?
    assert article.comments_locked?
  end

  test "destroy requires a signed-in superuser" do
    assert_no_difference("Article.count") do
      delete article_path(articles(:published))
    end
  end
end
