require "test_helper"

class DeveloperLoginTest < ActionDispatch::IntegrationTest
  setup do
    @env = ENV.to_h.slice("ADMIN_USER_ID", "ADMIN_USER_PASS")
    ENV["ADMIN_USER_ID"] = "dev"
    ENV["ADMIN_USER_PASS"] = "devpass"
  end

  teardown do
    %w[ ADMIN_USER_ID ADMIN_USER_PASS ].each { ENV[it] = @env[it] }
  end

  test ".env の ID・パスワードで開発者としてログインできる" do
    post session_path, params: { email_address: "dev", password: "devpass" }
    assert_redirected_to admin_root_path
    assert User.find_by!(email_address: "dev").developer?
  end

  test ".env のパスワードと違えばログインできない" do
    post session_path, params: { email_address: "dev", password: "wrong" }
    assert_redirected_to new_session_path
    assert_nil User.find_by(email_address: "dev")
  end

  test "開発者アカウントは画面からパスワードを変更できない" do
    post session_path, params: { email_address: "dev", password: "devpass" }
    patch admin_password_path, params: { current_password: "devpass", password: "changed123", password_confirmation: "changed123" }
    assert User.find_by!(email_address: "dev").authenticate("devpass")
  end
end
