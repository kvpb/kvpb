require "test_helper"

# The one action, called directly with every status it is ever asked for: the five Rails itself raises on
# its own, and one more nobody does — 503 — standing in for the easter egg's own real point, that any three
# digits reach this the same way (ErrorsControllerRoutingTest, below, covers reaching it for real instead)
class ErrorsControllerTest < ActionController::TestCase
  tests ErrorsController

  [ 400, 404, 406, 422, 500, 503 ].each do |status|
    test "status #{ status } renders and only its own number" do
      get :show, params: { status: status }

      assert_response status
      assert_select "#error_code", text: status.to_s
      assert_select "#wordmark", count: 1
      assert_select "#section_header", count: 0
      assert_select "#theme_toggle", count: 0
      assert_select "#copyright_notice_block", count: 1
      assert_select "footer#signature", count: 1
    end
  end
end

# config.exceptions_app only replaces Rails' own interactive diagnostics page once
# action_dispatch.show_detailed_exceptions is false, which development and, deliberately, this very
# test environment (so a real exception's full backtrace still shows by default) both leave true — so
# it is switched off just here, once, for exactly the one request each of these makes, to prove the
# wiring itself (routes.rb, config.exceptions_app, the errors/ layout) actually reaches ErrorsController
class ErrorsControllerRoutingTest < ActionDispatch::IntegrationTest
  def without_detailed_exceptions
    key = "action_dispatch.show_detailed_exceptions"
    old = Rails.application.env_config[ key ]
    Rails.application.env_config[ key ] = false
    yield
  ensure
    Rails.application.env_config[ key ] = old
  end

  test "a route nothing matches gets the site's own 404, not Rails' default one" do
    without_detailed_exceptions { get "/this-page-was-never-a-real-one" }

    assert_response :not_found
    assert_select "#error_code", text: "404"
    assert_select "nav a#read"
  end

  test "an old browser is turned away to its own page, not turned away again once it gets there" do
    without_detailed_exceptions do
      get "/", headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.99 Safari/533.4" }
    end

    assert_response :not_acceptable
    assert_select "#error_code", text: "406"
  end

  test "kvpb.fr/404, typed directly, reaches this page too — nothing behind it has to actually be broken" do
    get "/404"

    assert_response :not_found
    assert_select "#error_code", text: "404"
  end

  test "kvpb.fr/503, a status nothing here ever really raises, reaches it all the same — the easter egg" do
    get "/503"

    assert_response 503
    assert_select "#error_code", text: "503"
  end

  # assert_response itself checks the response's status against Rack::Utils::HTTP_STATUS_CODES — the exact
  # gap this route's own comment explains for 510 — so it, too, has no idea 510 is real; the response itself
  # answers 510 regardless, read here off response.status directly instead
  test "kvpb.fr/510 reaches it too — real per the IANA registry, missing from the Rack gem's own list" do
    get "/510"
    assert_equal 510, response.status
    assert_select "#error_code", text: "510"
  end

  test "kvpb.fr/418 doesn't reach it — retired by the registry, same as 306, MDN's own page for it notwithstanding" do
    without_detailed_exceptions { get "/418" }

    assert_response :not_found
    assert_select "#error_code", text: "404"
  end

  test "kvpb.fr/499 isn't a status HTTP itself defines, so it isn't this page — it's a genuine 404 instead" do
    without_detailed_exceptions { get "/499" }

    assert_response :not_found
    assert_select "#error_code", text: "404"
  end

  test "kvpb.fr/200 is a real status, but not an error one, so it isn't this page either" do
    without_detailed_exceptions { get "/200" }

    assert_response :not_found
    assert_select "#error_code", text: "404"
  end
end

#	errors_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
