module ApplicationHelper
  FALLBACK_LOGO_PATH = "/diorama_logo.webp".freeze
  # 元の bgm.wav は 32bit float 形式で再生できないブラウザがあるため、16bit PCM に変換した版を使う
  FALLBACK_BGM_PATH = "/bgm_16bit.wav".freeze

  MARKDOWN_EXTENSIONS = { tables: true, autolink: true, strikethrough: true, no_intra_emphasis: true, fenced_code_blocks: true }.freeze
  MARKDOWN_TAGS = %w[ p br h1 h2 h3 h4 h5 h6 strong em del ul ol li a table thead tbody tr th td blockquote code pre hr ].freeze
  MARKDOWN_ATTRIBUTES = %w[ href target rel style ].freeze

  # CMS で登録されたロゴ。未登録なら public/diorama_logo.webp
  def site_logo_source
    logo = current_site_setting.logo
    logo.attached? ? url_for(logo) : FALLBACK_LOGO_PATH
  end

  # CMS で登録された BGM。未登録なら public/bgm_16bit.wav
  def site_bgm_source
    bgm = current_site_setting.bgm
    bgm.attached? ? url_for(bgm) : FALLBACK_BGM_PATH
  end

  # 料金表用。生 HTML は無効化し、出力をさらに sanitize する
  def markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true, link_attributes: { target: "_blank", rel: "noopener" })
    html = Redcarpet::Markdown.new(renderer, MARKDOWN_EXTENSIONS).render(text)
    sanitize(html, tags: MARKDOWN_TAGS, attributes: MARKDOWN_ATTRIBUTES)
  end

  def dot_date(date)
    date&.strftime("%Y.%m.%d")
  end

  private
    def current_site_setting
      @current_site_setting ||= SiteSetting.with_attached_logo.with_attached_bgm.first || SiteSetting.new
    end
end
