require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "assigns an identifier from the headline when blank" do
    article = Article.create!(headline: "Hello World", body: "Body")
    assert_equal "hello-world", article.identifier
  end

  test "disambiguates identifiers that would otherwise collide" do
    Article.create!(headline: "Hello World", body: "Body")
    other = Article.create!(headline: "Hello World", body: "Body")
    assert_equal "hello-world-2", other.identifier
  end

  test "does not overwrite an explicitly assigned identifier" do
    article = Article.create!(headline: "Hello World", body: "Body", identifier: "custom-identifier")
    assert_equal "custom-identifier", article.identifier
  end

  test "to_param returns the identifier" do
    assert_equal articles(:published).identifier, articles(:published).to_param
  end

  test "published scope excludes drafts and future-dated articles" do
    assert_includes Article.published, articles(:published)
    assert_not_includes Article.published, articles(:draft)
  end

  test "published? reflects published_at" do
    assert articles(:published).published?
    assert_not articles(:draft).published?
  end
end
