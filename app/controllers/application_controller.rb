class ApplicationController < ActionController::Base
  include Authentication
  # 公開側は認証なし。管理画面（Admin::BaseController）でのみ認証を必須にする
  allow_unauthenticated_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
