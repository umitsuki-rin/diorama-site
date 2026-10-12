class News < ApplicationRecord
  include Publishable

  validates :title, presence: true, length: { maximum: 255 }
  validates :published_on, presence: true

  # 公開日が未来のもの（予約公開）は含めない
  scope :published, -> { where(status: :published).where(published_on: ..Date.current) }
  scope :latest_first, -> { order(published_on: :desc, id: :desc) }
end
