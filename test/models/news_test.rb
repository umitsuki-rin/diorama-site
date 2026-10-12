require "test_helper"

class NewsTest < ActiveSupport::TestCase
  test "published は公開済みかつ公開日が今日以前のものだけ" do
    visible = News.create!(title: "公開", published_on: Date.current, status: :published)
    News.create!(title: "予約", published_on: Date.tomorrow, status: :published)
    News.create!(title: "下書き", published_on: Date.current, status: :draft)

    assert_equal [ visible ], News.published.to_a
  end
end
