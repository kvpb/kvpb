require "test_helper"

class SearchTest < ActionDispatch::IntegrationTest
  XHR = { "X-Requested-With" => "XMLHttpRequest" }.freeze

  test "a visit to the search address is sent home rather than served a results page" do
    get search_path( q: "published" )
    assert_redirected_to root_path
  end

  test "the overlay's own request gets the cards back" do
    get search_path( q: "published" ), headers: XHR
    assert_response :success
    assert_select "a.search_result_card .search_result_title", text: "A published article"
    assert_select "a.search_result_card .search_result_kind", text: "article"
  end

  test "drafts are never found" do
    get search_path( q: "draft" ), headers: XHR
    assert_select ".search_result_card", count: 0
    assert_select ".search_no_results"
  end

  test "a query too short to mean anything finds nothing" do
    get search_path( q: "p" ), headers: XHR
    assert_select ".search_result_card", count: 0
  end

  test "albums and prints are found only once published" do
    Album.create!( title: "Kyoto in autumn", published_at: 1.day.ago )
    Album.create!( title: "Kyoto unfinished" )
    Print.create!( title: "Kyoto lantern", published_at: 1.day.ago )
    Print.create!( title: "Kyoto sketch" )

    get search_path( q: "kyoto" ), headers: XHR
    assert_select ".search_result_card", count: 2
    assert_select ".search_result_title", text: "Kyoto in autumn"
    assert_select ".search_result_title", text: "Kyoto lantern"
  end

  test "the about me page is found by a skill it lists, once and saying which, and not by one it leaves out" do
    Skill.create!( name: "Ruby", category: :programming_languages )
    Skill.create!( name: "Rubyist at heart", category: :activities_interests )

    get search_path( q: "ruby" ), headers: XHR
    assert_select ".search_result_card", count: 1
    assert_select ".search_result_title", text: "get to know & contact"
    assert_select ".search_result_detail", text: "Ruby"
  end

  test "no skill or milestone is a result of its own, only the page they are on" do
    Skill.create!( name: "Ruby", category: :programming_languages )
    Milestone.create!( title: "web designer", organization: "Ruby Studio", starts_on: Date.new( 2015, 8, 1 ), kind: :work )

    get search_path( q: "ruby" ), headers: XHR
    assert_select ".search_result_card", count: 1
    assert_select ".search_result_kind", text: "skill", count: 0
    assert_select ".search_result_kind", text: "milestone", count: 0
  end

  test "the about me page is found by the title, organization or place of a milestone" do
    Milestone.create!( title: "web designer", organization: "Studio Aurore", location: "Lyon", starts_on: Date.new( 2015, 8, 1 ), kind: :work )

    %w[designer aurore lyon].each do |query|
      get search_path( q: query ), headers: XHR
      assert_select ".search_result_title", text: "get to know & contact"
      assert_select ".search_result_detail", text: "web designer"
    end
  end

  test "a hidden milestone does not lead to the about me page" do
    Milestone.create!( title: "web designer", organization: "Studio Aurore", location: "Lyon", starts_on: Date.new( 2015, 8, 1 ), kind: :work, hidden: true )

    get search_path( q: "aurore" ), headers: XHR
    assert_select ".search_result_card", count: 0
  end

  test "the about me page is linked at the site's own address, not at one of its own" do
    Skill.create!( name: "Ruby", category: :programming_languages )

    get search_path( q: "ruby" ), headers: XHR

    assert_select ".search_result_card[href='#{ root_path }']", count: 1
    assert_select ".search_result_card[href='/gettoknowandcontact']", count: 0
  end

  test "the bar asks for a search, the same word the menu uses" do
    get root_path

    assert_select "#search_overlay input[placeholder='search']"
    assert_select "#search_overlay input[placeholder='find']", count: 0
  end

  test "a section is found under any of the words for it, once there is something in it" do
    get search_path( q: "photos" ), headers: XHR
    assert_select ".search_result_kind", text: "section", count: 0

    Album.create!( title: "Kyoto in autumn", published_at: 1.day.ago )

    %w[photos albums gallery see].each do |query|
      get search_path( q: query ), headers: XHR
      assert_select ".search_result_kind", text: "section"
      assert_select ".search_result_title", text: "gallery"
      assert_select ".search_result_detail", text: /1 album/
    end
  end

  test "the read section is found once an article is published" do
    get search_path( q: "journal" ), headers: XHR
    assert_select ".search_result_title", text: "journal"
    assert_select ".search_result_detail", text: /latest: A locked article|latest: An article with comments locked|latest: A published article/
  end

  test "the about me section is always found, and the sections that stay empty never are" do
    get search_path( q: "contact" ), headers: XHR
    assert_select ".search_result_title", text: "get to know & contact"

    %w[listen music watch films].each do |query|
      get search_path( q: query ), headers: XHR
      assert_select ".search_result_card", count: 0
    end
  end

  test "an album is found by a photo's place, camera, lens or author, or by a passage written in it, in published albums only, once each" do
    published = Album.create!( title: "Kyoto in autumn", published_at: 1.day.ago )
    draft = Album.create!( title: "Kyoto unfinished" )
    published.photos.create!( position: 1, place: "Fushimi Inari", camera: "Leica M11", lens: "Summilux 35mm", author: "Karl" )
    published.photos.create!( position: 3, place: "Fushimi Inari", camera: "Leica M11" )
    draft.photos.create!( position: 1, place: "Fushimi Draft" )
    published.passages.create!( position: 2, heading: "12 November 2025, Wednesday", body: "The lanterns were lit." )
    draft.passages.create!( position: 2, body: "The lanterns stayed dark." )

    get search_path( q: "fushimi" ), headers: XHR
    assert_select ".search_result_card", count: 1
    assert_select ".search_result_kind", text: "album"
    assert_select ".search_result_title", text: "Kyoto in autumn"
    assert_select ".search_result_detail", text: "Fushimi Inari · Leica M11 · Summilux 35mm · Karl"

    get search_path( q: "leica" ), headers: XHR
    assert_select ".search_result_card", count: 1

    get search_path( q: "lanterns" ), headers: XHR
    assert_select ".search_result_card", count: 1
    assert_select ".search_result_title", text: "Kyoto in autumn"
    assert_select ".search_result_detail", text: "The lanterns were lit."
  end

  test "no photo or passage is a result of its own, only the album page they are in" do
    album = Album.create!( title: "Kyoto in autumn", published_at: 1.day.ago )
    album.photos.create!( position: 1, place: "Fushimi Inari" )

    get search_path( q: "fushimi" ), headers: XHR
    assert_select ".search_result_kind", text: "photo", count: 0
    assert_select ".search_result_kind", text: "passage", count: 0
  end

  test "the Hall of Fame is never searched" do
    Honoree.create!( name: "Zzyzx", body: "Published, and still linked from nowhere.", published_at: 1.day.ago )

    get search_path( q: "zzyzx" ), headers: XHR
    assert_select ".search_result_card", count: 0
  end

  test "the characters LIKE treats specially are matched literally" do
    Skill.create!( name: "100% sure", category: :languages )
    Skill.create!( name: "1000 sure", category: :languages )

    get search_path( q: "100%" ), headers: XHR
    assert_select ".search_result_detail", text: "100% sure"
    assert_select ".search_result_detail", text: /1000/, count: 0
  end
end

#	search_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
