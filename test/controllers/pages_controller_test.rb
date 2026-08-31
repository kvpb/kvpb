require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "listen redirects guests to root, since music is always empty for now" do
    get listen_path

    assert_redirected_to root_path
  end

  test "listen still renders for a signed-in admin" do
    sign_in_as( users( :one ) )

    get listen_path

    assert_response :success
  end

  test "watch redirects guests to root, since films is always empty for now" do
    get watch_path

    assert_redirected_to root_path
  end

  test "watch still renders for a signed-in admin" do
    sign_in_as( users( :one ) )

    get watch_path

    assert_response :success
  end

  test "the tab reads KVPB.FR on the main page, and the full name is kept for search engines only" do
    get root_path

    assert_select "title", text: "KVPB.FR"
    assert_select "meta[name='title'][content='Karl Vincent Pierre Bertin AKA Karl Thomas George West']"
    assert_select "meta[property='og:title'][content='Karl Vincent Pierre Bertin AKA Karl Thomas George West']"
  end

  test "code redirects guests to root, since it has no content yet" do
    get code_path

    assert_redirected_to root_path
  end

  test "code still renders for a signed-in admin" do
    sign_in_as( users( :one ) )

    get code_path

    assert_response :success
  end

  test "map redirects guests to root, since it has no content yet" do
    get map_path

    assert_redirected_to root_path
  end

  test "map still renders for a signed-in admin" do
    sign_in_as( users( :one ) )

    get map_path

    assert_response :success
  end

  test "the menu shows code and map as dead entries, without a link, while they are empty" do
    get root_path

    assert_select "span#code.section_empty"
    assert_select "span#map.section_empty"
    assert_select "a#code", false
    assert_select "a#map", false
  end
end

#	pages_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
