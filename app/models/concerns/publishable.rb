# 下書き／公開の切り替えを持つモデル（Song, News）で共有する
module Publishable
  extend ActiveSupport::Concern

  STATUS_LABELS = { "draft" => "下書き", "published" => "公開" }.freeze

  included do
    enum :status, { draft: 0, published: 1 }, default: :draft, validate: true
  end

  def status_label
    STATUS_LABELS.fetch(status)
  end
end
