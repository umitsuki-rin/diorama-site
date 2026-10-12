# ログイン中のユーザーが自分のパスワードを変更する
class Admin::PasswordsController < Admin::BaseController
  before_action :set_user

  def edit
  end

  def update
    if @user.developer?
      redirect_to edit_admin_password_path, alert: "開発者アカウントのパスワードは .env で管理しています。"
    elsif !@user.authenticate(params[:current_password].to_s)
      @user.errors.add(:base, "現在のパスワードが違います。")
      render :edit, status: :unprocessable_entity
    elsif @user.update(password_params)
      # ほかの端末のログインは解除する
      @user.sessions.where.not(id: Current.session.id).destroy_all
      redirect_to edit_admin_password_path, notice: "パスワードを変更しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def password_params
      params.permit(:password, :password_confirmation).tap do |permitted|
        permitted[:password] = permitted[:password].presence || ""
      end
    end
end
