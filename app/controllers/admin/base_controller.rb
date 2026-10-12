class Admin::BaseController < ApplicationController
  before_action :require_authentication

  layout "admin"

  private
    # 「下書き保存」「公開する」どちらのボタンで送信されたかを status に反映する
    def submitted_status
      params[:status].presence_in(%w[ draft published ])
    end
end
