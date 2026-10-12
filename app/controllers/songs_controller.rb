# SONGS の白いカード（Turbo Frame "songs_panel"）に読み込む全楽曲一覧・楽曲詳細
class SongsController < ApplicationController
  # Turbo Frame 以外で直接開かれたらトップに戻す
  before_action -> { redirect_to root_path unless turbo_frame_request? }

  def index
    @songs = Song.published.in_registration_order.with_attached_jacket
  end

  def show
    @song = Song.published.with_attached_jacket.find(params[:id])
    @from_list = params[:from] == "list"
  end
end
