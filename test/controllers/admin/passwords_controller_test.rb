require "test_helper"

class Admin::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "現在のパスワードが合っていれば変更できる" do
    patch admin_password_path, params: { current_password: "password", password: "newpassword1", password_confirmation: "newpassword1" }
    assert_redirected_to edit_admin_password_path
    assert users(:one).reload.authenticate("newpassword1")
  end

  test "現在のパスワードが違うと変更できない" do
    patch admin_password_path, params: { current_password: "wrong", password: "newpassword1", password_confirmation: "newpassword1" }
    assert_response :unprocessable_entity
    assert users(:one).reload.authenticate("password")
  end

  test "確認用と一致しない・短すぎるパスワードは変更できない" do
    patch admin_password_path, params: { current_password: "password", password: "newpassword1", password_confirmation: "other" }
    assert_response :unprocessable_entity

    patch admin_password_path, params: { current_password: "password", password: "short", password_confirmation: "short" }
    assert_response :unprocessable_entity
    assert users(:one).reload.authenticate("password")
  end
end
