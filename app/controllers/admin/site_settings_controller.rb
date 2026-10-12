class Admin::SiteSettingsController < Admin::BaseController
  before_action :set_site_setting

  def show
  end

  def edit
  end

  def update
    if @site_setting.update(site_setting_params)
      @site_setting.logo.purge_later if params[:remove_logo] == "1" && site_setting_params[:logo].blank?
      @site_setting.bgm.purge_later if params[:remove_bgm] == "1" && site_setting_params[:bgm].blank?
      redirect_to admin_site_setting_path, notice: "サイト設定を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_site_setting
      @site_setting = SiteSetting.instance
    end

    def site_setting_params
      params.fetch(:site_setting, {}).permit(:logo, :bgm)
    end
end
