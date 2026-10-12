# robots.txt と sitemap.xml（URL をリクエストのホストから組み立てるため動的に返す）
class SeoController < ApplicationController
  def robots
    render plain: <<~TXT
      User-agent: *
      Allow: /
      Disallow: /admin
      Disallow: /session
      Disallow: /passwords

      Sitemap: #{sitemap_url}
    TXT
  end

  def sitemap
    @last_modified = [ Song.published.maximum(:updated_at), News.published.maximum(:updated_at), Profile.maximum(:updated_at) ].compact.max
    respond_to { |format| format.xml }
  end
end
