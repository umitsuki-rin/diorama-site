class Admin::ProfilesController < Admin::BaseController
  before_action :set_profile

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to admin_profile_path, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_profile
      @profile = Profile.instance
    end

    def profile_params
      params.expect(profile: %i[ body image price_table request_notes achievements x_url youtube_url niconico_url note_url ])
    end
end
