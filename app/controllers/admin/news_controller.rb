class Admin::NewsController < Admin::BaseController
  before_action :set_news, only: %i[ edit update destroy ]

  def index
    @news_list = News.latest_first
  end

  def new
    @news = News.new(published_on: Date.current)
  end

  def create
    @news = News.new(news_params)
    @news.status = submitted_status if submitted_status

    if @news.save
      redirect_to admin_news_index_path, notice: "ニュース「#{@news.title}」を#{@news.status_label}として登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @news.assign_attributes(news_params)
    @news.status = submitted_status if submitted_status

    if @news.save
      redirect_to admin_news_index_path, notice: "ニュース「#{@news.title}」を#{@news.status_label}として保存しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news.destroy!
    redirect_to admin_news_index_path, notice: "ニュース「#{@news.title}」を削除しました。", status: :see_other
  end

  private
    def set_news
      @news = News.find(params[:id])
    end

    def news_params
      params.expect(news: %i[ title body published_on ])
    end
end
