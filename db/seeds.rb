# 管理者アカウント（公開側にサインアップ画面は無いので、ここか rails console で作成する）
#   ADMIN_USER_ID=admin@example.com ADMIN_USER_PASS=xxxxxxxx bin/rails db:seed
email = ENV["ADMIN_USER_ID"].presence
password = ENV["ADMIN_USER_PASS"].presence

if email && password
  user = User.find_or_initialize_by(email_address: email)
  user.password = password
  user.save!
  puts "管理者アカウントを作成／更新しました: #{user.email_address}"
else
  puts "ADMIN_USER_ID / ADMIN_USER_PASS が未設定のため、管理者アカウントは作成しませんでした。"
end

SiteSetting.instance
Profile.instance

# 開発用のサンプルデータ（SEED_SAMPLE=1 のときだけ）
if ENV["SEED_SAMPLE"].present? && !Rails.env.production?
  Profile.instance.update!(
    body: "DIORAMA（ジオラマ）です。\n箱庭のような小さな世界を、音で描いています。\nボカロ曲の制作のほか、楽曲提供やアレンジのご依頼も受け付けています。",
    achievements: "2024年 〇〇〇〇 楽曲提供\n2023年 〇〇〇〇 アレンジ担当\n2022年 ボカロ曲「〇〇〇〇」100万回再生",
    price_table: "| 内容 | 料金 | 納期 |\n| --- | --- | --- |\n| 作詞・作曲・編曲 | ¥00,000〜 | 1ヶ月〜 |\n| 編曲のみ | ¥00,000〜 | 3週間〜 |\n| ミックス | ¥00,000〜 | 2週間〜 |\n\n※ 金額は目安です。内容により変動します。",
    request_notes: "・ご依頼はお問い合わせフォームからお願いします。\n・スケジュールによってはお受けできない場合があります。",
    x_url: "https://x.com/",
    youtube_url: "https://www.youtube.com/",
    niconico_url: "https://www.nicovideo.jp/",
    note_url: "https://note.com/"
  )

  6.times do |i|
    Song.find_or_create_by!(title: "サンプル楽曲 #{i + 1}") do |song|
      song.description = "サンプル楽曲 #{i + 1} の詳細です。"
      song.released_on = Date.new(2024, 1, 1) + (i * 40).days
      song.youtube_url = "https://www.youtube.com/"
      song.niconico_url = "https://www.nicovideo.jp/"
      song.spotify_url = "https://open.spotify.com/" if i.even?
      song.apple_music_url = "https://music.apple.com/" if i.even?
      song.amazon_music_url = "https://music.amazon.co.jp/" if i % 3 == 0
      song.awa_url = "https://s.awa.fm/" if i % 3 == 0
      song.status = i == 5 ? :draft : :published
    end
  end

  8.times do |i|
    News.find_or_create_by!(title: "「サンプル楽曲 #{i + 1}」を公開しました。") do |news|
      news.body = "新曲「サンプル楽曲 #{i + 1}」を公開しました。\nぜひお聴きください。"
      news.published_on = Date.current - (i * 9).days
      news.status = :published
    end
  end
  News.find_or_create_by!(title: "予約公開のお知らせ") do |news|
    news.body = "予約公開のサンプルです。"
    news.published_on = Date.current + 7.days
    news.status = :published
  end

  puts "サンプルデータを作成しました。"
end
