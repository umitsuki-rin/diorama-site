class Admin::DashboardController < Admin::BaseController
  def show
    @published_songs_count = Song.published.count
    @published_news_count = News.published.count
    @drafts_count = Song.draft.count + News.draft.count
    @unresponded_contacts_count = Contact.unresponded.count
  end
end
