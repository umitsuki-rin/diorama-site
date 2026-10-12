class Contact < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :company_name, length: { maximum: 100 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :body, presence: true, length: { maximum: 5000 }

  scope :latest_first, -> { order(created_at: :desc, id: :desc) }
  scope :unresponded, -> { where(responded: false) }
end
