class Song < ApplicationRecord
  include Publishable
  include UrlValidatable

  # 公開側のアイコン表示と CMS のフォームの両方でこの順に回す
  STREAMING_SERVICES = [
    { key: :youtube_url,      name: "YouTube",      icon: "songs/youtube.webp" },
    { key: :niconico_url,     name: "ニコニコ",     icon: "songs/niconico.webp" },
    { key: :spotify_url,      name: "Spotify",      icon: "songs/spotify.webp" },
    { key: :apple_music_url,  name: "Apple Music",  icon: "songs/apple-music.webp" },
    { key: :amazon_music_url, name: "Amazon Music", icon: "songs/amazon-music.webp" },
    { key: :awa_url,          name: "AWA",          icon: "songs/awa.webp" }
  ].freeze

  has_one_attached :jacket

  validates :title, presence: true, length: { maximum: 255 }
  validates_urls(*STREAMING_SERVICES.map { it[:key] })

  scope :published, -> { where(status: :published) }
  scope :in_registration_order, -> { order(:created_at, :id) }

  # URL が登録されている配信先だけを返す
  def streaming_links
    STREAMING_SERVICES.filter_map do |service|
      url = public_send(service[:key])
      service.merge(url: url) if url.present?
    end
  end
end
