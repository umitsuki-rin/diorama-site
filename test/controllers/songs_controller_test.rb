require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "Turbo Frame からは全楽曲一覧を返す" do
    Song.create!(title: "公開曲", status: :published)
    Song.create!(title: "下書き曲")

    get songs_path, headers: { "Turbo-Frame" => "songs_panel" }
    assert_response :success
    assert_match "公開曲", response.body
    assert_no_match "下書き曲", response.body
  end

  test "Turbo Frame からは楽曲詳細を返す" do
    song = Song.create!(title: "公開曲", description: "曲の詳細", status: :published)

    get song_path(song), headers: { "Turbo-Frame" => "songs_panel" }
    assert_response :success
    assert_match "曲の詳細", response.body
  end

  test "下書きの楽曲詳細は見られない" do
    song = Song.create!(title: "下書き曲")

    get song_path(song), headers: { "Turbo-Frame" => "songs_panel" }
    assert_response :not_found
  end

  test "直接開かれたらトップに戻す" do
    get songs_path
    assert_redirected_to root_path
  end
end
