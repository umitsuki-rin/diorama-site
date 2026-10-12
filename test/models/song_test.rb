require "test_helper"

class SongTest < ActiveSupport::TestCase
  test "曲名は必須" do
    assert_not Song.new.valid?
  end

  test "配信先 URL は http(s) のみ許可" do
    song = Song.new(title: "曲", youtube_url: "javascript:alert(1)")
    assert_not song.valid?
    assert song.errors.of_kind?(:youtube_url, :invalid)

    song.youtube_url = "https://www.youtube.com/watch?v=x"
    assert song.valid?
  end

  test "streaming_links は登録済みの配信先だけを定義順で返す" do
    song = Song.new(title: "曲", awa_url: "https://s.awa.fm/x", youtube_url: "https://youtu.be/x")
    assert_equal %i[ youtube_url awa_url ], song.streaming_links.map { it[:key] }
  end

  test "初期値は下書き" do
    assert Song.new.draft?
  end
end
