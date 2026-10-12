class HomeController < ApplicationController
  SONGS_LIMIT = 4
  NEWS_LIMIT = 6

  def show
    @songs = Song.published.in_registration_order.with_attached_jacket.limit(SONGS_LIMIT)
    @has_more_songs = Song.published.count > SONGS_LIMIT
    @profile = Profile.instance
    @news_list = News.published.latest_first.limit(NEWS_LIMIT)
    @contact = Contact.new
    @all_songs = Song.published.in_registration_order.with_attached_jacket
  end
end
