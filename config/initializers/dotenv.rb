# 開発・テスト環境では .env を読み込む（既に設定されている環境変数は上書きしない）。
# 本番は Docker / Kamal 側で環境変数を渡す
if Rails.env.local?
  env_file = Rails.root.join(".env")

  if env_file.exist?
    env_file.each_line do |line|
      next if line.strip.empty? || line.lstrip.start_with?("#")

      key, value = line.strip.split("=", 2)
      next if key.blank? || value.nil?

      ENV[key] ||= value.strip.delete_prefix('"').delete_suffix('"')
    end
  end
end
