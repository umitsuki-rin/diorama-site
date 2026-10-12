class SiteSetting < ApplicationRecord
  has_one_attached :logo
  has_one_attached :bgm

  validate :logo_must_be_image, :bgm_must_be_audio

  def self.instance
    first_or_create!
  end

  private
    def logo_must_be_image
      errors.add(:logo, "は画像ファイルを選択してください") if logo.attached? && !logo.content_type.to_s.start_with?("image/")
    end

    def bgm_must_be_audio
      errors.add(:bgm, "は音声ファイルを選択してください") if bgm.attached? && !bgm.content_type.to_s.start_with?("audio/")
    end
end
