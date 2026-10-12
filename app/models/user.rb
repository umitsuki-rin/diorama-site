class User < ApplicationRecord
  PASSWORD_MIN_LENGTH = 8

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  # 開発者アカウントのパスワードは .env で管理するので対象外
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true, unless: :developer?

  class << self
    # .env の ADMIN_USER_ID / ADMIN_USER_PASS（両方あるときだけ有効）
    def developer_credentials
      login = ENV["ADMIN_USER_ID"].to_s.strip.downcase
      password = ENV["ADMIN_USER_PASS"].to_s
      [ login, password ] if login.present? && password.present?
    end

    # .env の ID・パスワードと一致したら開発者アカウントを返す（無ければ作り、パスワードは .env に合わせる）
    def authenticate_developer(login, password)
      developer_login, developer_password = developer_credentials
      return unless developer_login

      matched = ActiveSupport::SecurityUtils.secure_compare(login.to_s.strip.downcase, developer_login) &
                ActiveSupport::SecurityUtils.secure_compare(password.to_s, developer_password)
      return unless matched

      find_or_initialize_by(email_address: developer_login).tap do |user|
        user.update!(password: developer_password) unless user.persisted? && user.authenticate(developer_password)
      end
    end
  end

  def developer?
    email_address.present? && email_address == self.class.developer_credentials&.first
  end
end
