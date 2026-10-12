require "test_helper"

class NewsControllerTest < ActionDispatch::IntegrationTest
  test "Turbo Frame からは詳細を返す" do
    news = News.create!(title: "お知らせ", body: "本文", published_on: Date.current, status: :published)

    get news_path(news), headers: { "Turbo-Frame" => "news_panel" }
    assert_response :success
    assert_match "本文", response.body
  end

  test "下書きの詳細は見られない" do
    news = News.create!(title: "下書き", published_on: Date.current)

    get news_path(news), headers: { "Turbo-Frame" => "news_panel" }
    assert_response :not_found
  end

  test "直接開かれたらトップに戻す" do
    get news_index_path
    assert_redirected_to root_path
  end
end
