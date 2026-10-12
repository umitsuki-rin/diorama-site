# 管理画面のユーザー追加・削除（開発者アカウントのみ）
class Admin::UsersController < Admin::BaseController
  before_action :require_developer
  before_action :set_user, only: :destroy

  def index
    @users = User.order(:created_at, :id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.developer?
      @user.errors.add(:email_address, "は開発者アカウントと同じため使えません")
      render :new, status: :unprocessable_entity
    elsif @user.save
      redirect_to admin_users_path, notice: "ユーザー「#{@user.email_address}」を追加しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.developer? || @user == Current.user
      redirect_to admin_users_path, alert: "このユーザーは削除できません。"
    else
      @user.destroy!
      redirect_to admin_users_path, notice: "ユーザー「#{@user.email_address}」を削除しました。", status: :see_other
    end
  end

  private
    def require_developer
      redirect_to admin_root_path, alert: "この画面は開発者アカウントのみ利用できます。" unless Current.user&.developer?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[ email_address password password_confirmation ])
    end
end
