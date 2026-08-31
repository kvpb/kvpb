require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "edit requires a signed-in admin" do
    get settings_path
    assert_redirected_to root_path

    sign_in_as( users( :two ) )
    get settings_path
    assert_redirected_to root_path
  end

  test "update requires a signed-in admin" do
    patch settings_path, params: { setting: { twitter_visible: "1" } }
    assert_redirected_to root_path
    assert_not Setting.current.twitter_visible?
  end

  test "edit renders for a signed-in admin" do
    sign_in_as( users( :one ) )

    get settings_path

    assert_response :success
    assert_select "#section_header", text: /back end/i
    assert_select "input[type=checkbox][name='setting[twitter_visible]']"
    assert_select "input[type=checkbox][name='setting[github_visible]']"
    assert_select "input[type=checkbox][name='setting[youtube_visible]']"
  end

  test "update shows and hides the menu entries" do
    sign_in_as( users( :one ) )

    patch settings_path, params: { setting: { twitter_visible: "1", github_visible: "0", youtube_visible: "1" } }

    assert_redirected_to settings_path
    assert Setting.current.twitter_visible?
    assert_not Setting.current.github_visible?
    assert Setting.current.youtube_visible?
  end

  test "the menu hides Twitter\\X and YouTube by default and keeps their markup out of the page, but shows GitHub" do
    get root_path

    assert_select "#checkout_TwitterX", false
    assert_select "#checkout_GitHub"
    assert_select "#checkout_YouTube", false
  end

  test "the menu shows Twitter\\X and YouTube once they are turned on, and hides GitHub once it is turned off" do
    Setting.current.update!( twitter_visible: true, github_visible: false, youtube_visible: true )

    get root_path

    assert_select "#checkout_TwitterX"
    assert_select "#checkout_GitHub", false
    assert_select "#checkout_YouTube"
  end
end

#	settings_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
