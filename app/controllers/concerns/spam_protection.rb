# お問い合わせフォームのボット対策
#   1. ハニーポット：人には見えない「フリガナ」欄（contact[name_kana]）。本物の項目に見えるので、
#      ボット（AI 含む）は埋めてくる。入力があったら弾く
#   2. 送信までの時間：フォーム表示時刻を署名付きで埋め込み、速すぎる（または改ざん・期限切れの）送信を弾く
# 弾いたときも通常の完了画面を返し、ボットに検知されたことを悟らせない（保存はしない）
module SpamProtection
  extend ActiveSupport::Concern

  HONEYPOT_FIELD = :name_kana
  TIMESTAMP_FIELD = :form_token
  MIN_FILL_SECONDS = 3
  TOKEN_EXPIRES_IN = 1.day

  # フォームに埋め込むトークン（ビューからは ContactsHelper#spam_form_token で使う）
  def self.form_token
    verifier.generate(Time.current.to_f, expires_in: TOKEN_EXPIRES_IN, purpose: :contact_form)
  end

  def self.verifier
    Rails.application.message_verifier(:contact_spam_protection)
  end

  private
    # ボットと判定した理由（人間なら nil）
    def spam_reason
      return "honeypot" if params.dig(:contact, HONEYPOT_FIELD).present?

      rendered_at = SpamProtection.verifier.verified(params[TIMESTAMP_FIELD].to_s, purpose: :contact_form)
      return "invalid_token" unless rendered_at
      return "too_fast" if Time.current.to_f - rendered_at.to_f < MIN_FILL_SECONDS

      nil
    end
end
