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

class ArticleTest < ActiveSupport::TestCase
  test "assigns an identifier from the headline when blank" do
    article = Article.create!( headline: "Hello World", body: "Body" )
    assert_equal "hello-world", article.identifier
  end

  test "disambiguates identifiers that would otherwise collide" do
    Article.create!( headline: "Hello World", body: "Body" )
    other = Article.create!( headline: "Hello World", body: "Body" )
    assert_equal "hello-world-2", other.identifier
  end

  test "does not overwrite an explicitly assigned identifier" do
    article = Article.create!( headline: "Hello World", body: "Body", identifier: "custom-identifier" )
    assert_equal "custom-identifier", article.identifier
  end

  test "to_param returns the identifier" do
    assert_equal articles( :published ).identifier, articles( :published ).to_param
  end

  test "published scope excludes drafts and future-dated articles" do
    assert_includes Article.published, articles( :published )
    assert_not_includes Article.published, articles( :draft )
  end

  test "published? reflects published_at" do
    assert articles( :published ).published?
    assert_not articles( :draft ).published?
  end

  test "a draft can be saved without a body" do
    article = Article.new( headline: "Bare draft" )
    assert article.valid?
  end

  test "publishing requires a body" do
    article = Article.new( headline: "Scheduled", published_at: 1.day.from_now )
    assert_not article.valid?
    assert_includes article.errors.attribute_names, :body
  end

  test "a future published_at schedules rather than publishes" do
    article = Article.create!( headline: "Scheduled ahead", body: "Body", published_at: 1.day.from_now )
    assert_not article.published?
    assert_not_includes Article.published, article
  end
end

#	article_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
