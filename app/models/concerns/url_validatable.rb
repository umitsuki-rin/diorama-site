# http(s):// 形式の URL のみ許可する
module UrlValidatable
  extend ActiveSupport::Concern

  URL_FORMAT = %r{\Ahttps?://[^\s]+\z}

  class_methods do
    def validates_urls(*attributes)
      validates(*attributes, format: { with: URL_FORMAT, message: "は http:// または https:// で始まる URL を入力してください" }, allow_blank: true)
    end
  end
end
