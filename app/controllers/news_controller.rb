# NEWS カード中央の Turbo Frame（news_panel）に読み込む一覧・詳細
class NewsController < ApplicationController
  # Turbo Frame 以外で直接開かれたらトップに戻す
  before_action -> { redirect_to root_path unless turbo_frame_request? }

  def index
    @all = params[:all].present?
    @news_list = News.published.latest_first
    @news_list = @news_list.limit(HomeController::NEWS_LIMIT) unless @all
  end

  def show
    @news = News.published.find(params[:id])
    @back_to_all = params[:from] == "all"
  end
end
