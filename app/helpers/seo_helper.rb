# 検索エンジン・SNS 向けのメタ情報と構造化データ
module SeoHelper
  SITE_NAME = "DIORAMA".freeze
  DEFAULT_TITLE = "DIORAMA | ボカロP DIORAMA 公式サイト".freeze
  DEFAULT_DESCRIPTION = "ボカロP「DIORAMA」の公式サイト。楽曲・プロフィール・お知らせ・楽曲制作のご依頼について掲載しています。".freeze
  DESCRIPTION_LENGTH = 120

  def seo_title
    content_for(:title).presence || DEFAULT_TITLE
  end

  # プロフィール文の冒頭から作る。未登録なら既定の文
  def seo_description
    body = @profile&.body.to_s.squish
    return DEFAULT_DESCRIPTION if body.blank?

    truncate("ボカロP「DIORAMA」公式サイト。#{body}", length: DESCRIPTION_LENGTH)
  end

  def seo_image_url
    absolute_asset_url(site_logo_source)
  end

  # schema.org の構造化データ（JSON-LD）。トップページでのみ出力する
  def structured_data(profile:, songs:)
    sns = [ profile.x_url, profile.youtube_url, profile.niconico_url, profile.note_url ].compact_blank

    artist = {
      "@type": "MusicGroup",
      "@id": "#{root_url}#artist",
      name: SITE_NAME,
      url: root_url,
      description: seo_description,
      genre: [ "VOCALOID", "J-POP" ],
      image: profile.image.attached? ? absolute_asset_url(url_for(profile.image)) : seo_image_url,
      sameAs: sns,
      track: songs.map { song_structured_data(it) }
    }.compact_blank

    data = {
      "@context": "https://schema.org",
      "@graph": [
        { "@type": "WebSite", "@id": "#{root_url}#website", name: SITE_NAME, url: root_url, inLanguage: "ja", publisher: { "@id": "#{root_url}#artist" } },
        artist
      ]
    }

    tag.script(json_escape(data.to_json).html_safe, type: "application/ld+json")
  end

  private
    def song_structured_data(song)
      {
        "@type": "MusicRecording",
        name: song.title,
        datePublished: song.released_on&.iso8601,
        url: song.youtube_url.presence || song.niconico_url.presence,
        image: (absolute_asset_url(url_for(song.jacket)) if song.jacket.attached?),
        byArtist: { "@id": "#{root_url}#artist" },
        sameAs: song.streaming_links.map { it[:url] }
      }.compact_blank
    end

    def absolute_asset_url(path)
      path.to_s.start_with?("http") ? path : "#{request.base_url}#{path}"
    end
end
