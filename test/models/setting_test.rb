require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "current returns the existing row instead of creating a duplicate" do
    assert_difference("Setting.count", 0) do
      assert_equal settings(:current), Setting.current
    end
  end

  test "current creates a row when none exists" do
    Setting.delete_all

    assert_difference("Setting.count", 1) do
      setting = Setting.current
      assert_not setting.registration_enabled?
    end
  end
end
