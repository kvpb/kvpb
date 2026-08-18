require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index lists only published articles for guests" do
    get read_path

    assert_response :success
    assert_match articles( :published ).headline, response.body
    assert_no_match articles( :draft ).headline, response.body
  end

  test "index lists drafts too for a signed-in superuser" do
    sign_in_as( users( :one ) )

    get read_path

    assert_match articles( :draft ).headline, response.body
  end

  test "index redirects guests to root when the journal is empty" do
    Article.published.destroy_all

    get read_path

    assert_redirected_to root_path
  end

  test "index still renders for a signed-in superuser when the journal is empty" do
    Article.published.destroy_all
    sign_in_as( users( :one ) )

    get read_path

    assert_response :success
  end

  test "show renders a published article for guests" do
    get article_path( articles( :published ) )

    assert_response :success
  end

  test "show 404s a draft for guests" do
    get article_path( articles( :draft ) )

    assert_response :not_found
  end

  test "show renders a draft for a signed-in superuser" do
    sign_in_as( users( :one ) )

    get article_path( articles( :draft ) )

    assert_response :success
  end

  test "new requires a signed-in superuser" do
    get new_article_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get new_article_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in superuser" do
    assert_no_difference( "Article.count" ) do
      post read_path, params: { article: { headline: "Hello", body: "Body" } }
    end
  end

  test "create builds an article as a draft by default" do
    sign_in_as( users( :one ) )

    assert_difference( "Article.count", 1 ) do
      post read_path, params: { article: { headline: "Hello World", body: "Body" } }
    end

    assert_not Article.find_by!( identifier: "hello-world" ).published?
  end

  test "update lets a superuser publish and lock comments" do
    sign_in_as( users( :one ) )
    article = articles( :draft )

    patch article_path( article ), params: { article: { published_at: Time.current, comments_locked: true } }

    article.reload
    assert article.published?
    assert article.comments_locked?
  end

  test "destroy requires a signed-in superuser" do
    assert_no_difference( "Article.count" ) do
      delete article_path( articles( :published ) )
    end
  end

  test "autosave create responds with json and switches the record to update mode" do
    sign_in_as( users( :one ) )

    assert_difference( "Article.count", 1 ) do
      post read_path( format: :json ), params: { article: { headline: "Autosaved draft" } }
    end

    assert_response :success
    body = JSON.parse( response.body )
    article = Article.find_by!( identifier: "autosaved-draft" )
    assert body[ "ok" ]
    assert_equal edit_article_path( article ), body[ "edit_url" ]
    assert_not article.published?
  end

  test "autosave create with a blank headline reports errors instead of creating a row" do
    sign_in_as( users( :one ) )

    assert_no_difference( "Article.count" ) do
      post read_path( format: :json ), params: { article: { headline: "" } }
    end

    assert_response :unprocessable_entity
    assert_not JSON.parse( response.body )[ "ok" ]
  end

  test "autosave update responds with json" do
    sign_in_as( users( :one ) )
    article = articles( :draft )

    patch article_path( article, format: :json ), params: { article: { lede: "Updated via autosave" } }

    assert_response :success
    assert JSON.parse( response.body )[ "ok" ]
    assert_equal "Updated via autosave", article.reload.lede
  end
end

#	articles_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
