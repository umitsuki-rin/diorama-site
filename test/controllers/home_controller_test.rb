require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "公開中の楽曲・ニュースだけを表示する" do
    Song.create!(title: "公開曲", status: :published)
    Song.create!(title: "下書き曲", status: :draft)
    News.create!(title: "公開ニュース", published_on: Date.current, status: :published)
    News.create!(title: "予約ニュース", published_on: Date.tomorrow, status: :published)

    get root_path
    assert_response :success
    assert_match "公開曲", response.body
    assert_no_match "下書き曲", response.body
    assert_match "公開ニュース", response.body
    assert_no_match "予約ニュース", response.body
  end

  test "楽曲は登録順に最大4件" do
    5.times { |i| Song.create!(title: "曲#{i}", status: :published) }

    get root_path
    assert_select "#songs article h3", count: 4
    assert_select "#songs article h3", text: "曲3"
    assert_select "#songs article h3", text: "曲4", count: 0
  end

  test "料金表の Markdown は生 HTML を無効化して表示する" do
    Profile.instance.update!(price_table: "| a | b |\n| - | - |\n| 1 | 2 |\n\n<script>alert(1)</script>")

    get root_path
    assert_select "#diorama .markdown-body table"
    assert_no_match "<script>alert(1)</script>", response.body
  end
end
