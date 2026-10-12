class Admin::SongsController < Admin::BaseController
  before_action :set_song, only: %i[ edit update destroy ]

  def index
    @songs = Song.in_registration_order.with_attached_jacket
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)
    @song.status = submitted_status if submitted_status

    if @song.save
      redirect_to admin_songs_path, notice: "楽曲「#{@song.title}」を#{@song.status_label}として登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @song.assign_attributes(song_params)
    @song.status = submitted_status if submitted_status

    if @song.save
      redirect_to admin_songs_path, notice: "楽曲「#{@song.title}」を#{@song.status_label}として保存しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @song.destroy!
    redirect_to admin_songs_path, notice: "楽曲「#{@song.title}」を削除しました。", status: :see_other
  end

  private
    def set_song
      @song = Song.find(params[:id])
    end

    def song_params
      params.expect(song: [ :title, :description, :released_on, :jacket, *Song::STREAMING_SERVICES.map { it[:key] } ])
    end
end
