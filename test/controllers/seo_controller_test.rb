require "test_helper"

class SeoControllerTest < ActionDispatch::IntegrationTest
  test "robots.txt は管理画面を除外し、サイトマップを示す" do
    get "/robots.txt"
    assert_response :success
    assert_match "Disallow: /admin", response.body
    assert_match "Sitemap: #{sitemap_url}", response.body
  end

  test "sitemap.xml にトップページを載せる" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_match "<loc>#{root_url}</loc>", response.body
  end

  test "トップページにメタ情報と構造化データを出す" do
    Profile.instance.update!(body: "箱庭のような世界を音で描いています。")
    Song.create!(title: "公開曲", status: :published, released_on: Date.new(2024, 1, 1))

    get root_path
    assert_select "title", SeoHelper::DEFAULT_TITLE
    assert_select "meta[name=description][content*=?]", "箱庭のような世界"
    assert_select "link[rel=canonical][href=?]", root_url
    assert_select "meta[property='og:image']"
    assert_select "meta[name='twitter:card'][content=summary_large_image]"
    assert_select "h1", 1
    assert_select "script[type='application/ld+json']", text: /"MusicRecording".*"公開曲"/
  end
end
