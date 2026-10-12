class SessionsController < ApplicationController
  layout "auth"
  before_action :require_authentication, only: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "しばらくしてから再度お試しください。" }

  def new
  end

  def create
    # 開発者は .env の ID・パスワード、それ以外は登録済みのメールアドレス・パスワードでログイン
    user = User.authenticate_developer(params[:email_address], params[:password]) ||
           User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "ID（メールアドレス）またはパスワードが違います。"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
