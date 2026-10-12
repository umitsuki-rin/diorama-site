require "test_helper"

class Admin::SongsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインならログイン画面へ" do
    get admin_songs_path
    assert_redirected_to new_session_path
  end

  test "「公開する」で公開として登録する" do
    sign_in_as users(:one)

    post admin_songs_path, params: { song: { title: "新曲" }, status: "published" }
    assert_redirected_to admin_songs_path
    assert Song.find_by!(title: "新曲").published?
  end

  test "「下書き保存」で下書きに戻す" do
    sign_in_as users(:one)
    song = Song.create!(title: "曲", status: :published)

    patch admin_song_path(song), params: { song: { title: "曲" }, status: "draft" }
    assert song.reload.draft?
  end
end
