require "test_helper"

class Admin::PagesTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "管理画面の各ページを表示できる" do
    song = Song.create!(title: "曲")
    news = News.create!(title: "ニュース", published_on: Date.current)
    contact = Contact.create!(name: "山田", email: "y@example.com", body: "本文")

    [ admin_root_path, admin_site_setting_path, edit_admin_site_setting_path, admin_profile_path, edit_admin_profile_path,
      admin_songs_path, new_admin_song_path, edit_admin_song_path(song),
      admin_news_index_path, new_admin_news_path, edit_admin_news_path(news),
      admin_contacts_path, admin_contact_path(contact) ].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "お問い合わせの対応済みを切り替える" do
    contact = Contact.create!(name: "山田", email: "y@example.com", body: "本文")

    patch admin_contact_path(contact)
    assert contact.reload.responded?
    patch admin_contact_path(contact)
    assert_not contact.reload.responded?
  end
end
