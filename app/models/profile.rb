class Profile < ApplicationRecord
  include UrlValidatable

  has_one_attached :image

  validates_urls :x_url, :youtube_url, :niconico_url, :note_url

  def self.instance
    first_or_create!
  end

  def achievement_list
    achievements.to_s.lines.map(&:strip).compact_blank
  end
end
