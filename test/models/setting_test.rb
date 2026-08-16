require "test_helper"

class SettingTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  test "current returns the existing row instead of creating a duplicate" do
    assert_difference( "Setting.count", 0 ) do
      assert_equal settings( :current ), Setting.current
    end
  end

  test "current creates a row when none exists" do
    Setting.delete_all

    assert_difference( "Setting.count", 1 ) do
      setting = Setting.current
      assert_not setting.registration_enabled?
    end
  end

  test "current always has a login_token" do
    assert settings( :current ).login_token.present?
  end

  test "rotating the login token changes it and emails superusers" do
    setting = settings( :current )
    previous_token = setting.login_token

    assert_emails 1 do
      setting.rotate_login_token!
    end

    assert_not_equal previous_token, setting.reload.login_token
    assert_equal [ users( :one ).email_address ], ActionMailer::Base.deliveries.last.to
  end
end

#	setting_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
