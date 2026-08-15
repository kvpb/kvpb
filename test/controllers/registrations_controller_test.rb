require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the disabled view when registration is closed" do
    Setting.current.update!(registration_enabled: false)

    get new_registration_path

    assert_response :success
    assert_select "p", text: "Registration is currently closed."
  end

  test "new renders the sign-up form when registration is open" do
    Setting.current.update!(registration_enabled: true)

    get new_registration_path

    assert_response :success
    assert_select "form"
  end

  test "create does not build a user while registration is closed" do
    Setting.current.update!(registration_enabled: false)

    assert_no_difference("User.count") do
      post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123" } }
    end
  end

  test "create builds a regular, non-superuser account while registration is open" do
    Setting.current.update!(registration_enabled: true)

    assert_difference("User.count", 1) do
      post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123" } }
    end

    assert_not User.find_by!(username: "newbie").superuser?
    assert cookies[:session_id]
  end

  test "create ignores an injected superuser param" do
    Setting.current.update!(registration_enabled: true)

    post registration_path, params: { user: { username: "newbie", email_address: "newbie@example.com", password: "password123", password_confirmation: "password123", superuser: true } }

    assert_not User.find_by!(username: "newbie").superuser?
  end
end
