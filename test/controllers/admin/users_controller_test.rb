require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @env = ENV.to_h.slice("ADMIN_USER_ID", "ADMIN_USER_PASS")
    ENV["ADMIN_USER_ID"] = "dev"
    ENV["ADMIN_USER_PASS"] = "devpass"
  end

  teardown do
    %w[ ADMIN_USER_ID ADMIN_USER_PASS ].each { ENV[it] = @env[it] }
  end

  test "開発者はユーザーを追加できる" do
    post session_path, params: { email_address: "dev", password: "devpass" }

    get admin_users_path
    assert_response :success

    assert_difference -> { User.count } do
      post admin_users_path, params: { user: { email_address: "staff@example.com", password: "staffpass1", password_confirmation: "staffpass1" } }
    end
    assert_redirected_to admin_users_path
    assert User.find_by!(email_address: "staff@example.com").authenticate("staffpass1")
  end

  test "短いパスワード・重複したIDでは追加できない" do
    post session_path, params: { email_address: "dev", password: "devpass" }

    assert_no_difference -> { User.count } do
      post admin_users_path, params: { user: { email_address: "staff@example.com", password: "short", password_confirmation: "short" } }
      post admin_users_path, params: { user: { email_address: users(:one).email_address, password: "staffpass1", password_confirmation: "staffpass1" } }
    end
    assert_response :unprocessable_entity
  end

  test "開発者はユーザーを削除できるが、自分は削除できない" do
    post session_path, params: { email_address: "dev", password: "devpass" }
    developer = User.find_by!(email_address: "dev")

    assert_difference -> { User.count }, -1 do
      delete admin_user_path(users(:two))
    end
    assert_no_difference -> { User.count } do
      delete admin_user_path(developer)
    end
  end

  test "開発者以外はユーザー管理を使えない" do
    sign_in_as users(:one)

    get admin_users_path
    assert_redirected_to admin_root_path
    assert_no_difference -> { User.count } do
      post admin_users_path, params: { user: { email_address: "x@example.com", password: "staffpass1", password_confirmation: "staffpass1" } }
    end
  end
end
