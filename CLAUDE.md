# CLAUDE.md

ボカロP「DIORAMA」の公式ホームページ。
このファイルには**表向きのホームページ（公開側）**と**CMS（管理画面）**の仕様をまとめる。

---

## 技術スタック

| 項目 | 内容 |
|---|---|
| フレームワーク | Rails 8.1（`rails new` 直後の状態） |
| Ruby | 4.0.5（`.ruby-version`） |
| テンプレート | Slim（`slim-rails`） |
| CSS | Tailwind CSS v4（`tailwindcss-rails`、エントリは `app/assets/tailwind/application.css`） |
| JS | importmap + Hotwire（Turbo / Stimulus） |
| アセット | Propshaft |
| DB | MySQL（`mysql2`） |
| 開発環境 | Docker Compose（WSL2 / Debian 上で実行） |

### 実装ルール

- ビューはすべて Slim で書く。既存の `layouts/application.html.erb` も Slim に置き換える。
- スタイルは Tailwind のユーティリティを基本とする。フォント、色、枠線装飾など繰り返し使うものは `app/assets/tailwind/application.css` の `@theme` に定義する。
- JS は Stimulus コントローラ単位で書く。npm ビルドは導入しない（importmap で完結させる）。
- 公開側のデータ（楽曲、プロフィール、ニュース、SNS、実績、料金表）は**すべて CMS で登録したもの**を表示する。ビューにハードコードしない。
- コマンドは WSL 側でコンテナ経由で実行する（例：`docker compose exec web bin/rails ...`）。

---

## 画面全体の構成

**1ページ構成**。背景の緑の額縁は画面に固定したまま、スクロールに応じて**中央のコンテンツだけがふわっと切り替わる**。

### 表示の流れ

1. アクセス時：`diorama_logo.png` を表示（オープニング）
2. 音楽のオン／オフを選択
3. 本編。スクロールで次の順に切り替わる
   1. SONGS
   2. DIORAMA（プロフィール）
   3. NEWS
   4. CONTACT

### 切り替え演出

| 遷移 | 演出 |
|---|---|
| SONGS → DIORAMA | 中央のコンテンツがふわっと（フェード＋わずかな移動）切り替わる |
| DIORAMA → NEWS | 中央のカードが**ページをめくる**ような演出 → 中身がふわっと表示 |
| NEWS → CONTACT | ページをめくる演出で表示 |
| NEWS 一覧 → NEWS 詳細 | ページをめくる演出で、中央部分に詳細を表示 |

- 逆方向へのスクロールでも同じ演出を逆再生する。
- `prefers-reduced-motion: reduce` のときはアニメーションを省略し、単純な切り替えにする。

### 背景（全画面共通・固定）

- 角丸の大きな額縁。背景は緑のグラデーション（左上が明るい水色寄りの緑、右下が深い緑）。
- 額縁の内側に複数の線が入る（外から順に）
  1. 淡いピンクの線
  2. ゴールドの二重線（グラデーションで光沢感）
  3. 淡い水色の線。四隅が内側に丸くえぐれた形（スカラップコーナー）
- 色の目安（デザインからの読み取りのため近似値）

| 用途 | 色 |
|---|---|
| 背景グラデーション（明） | `#6dbdb9` 付近 |
| 背景グラデーション（暗） | `#367b75` 付近 |
| 見出し（Archivo Black） | `#2f6b66` 付近 |
| Whisper 文字（SONGS / NEWS） | ベージュ `#d8bf95` 付近 |
| NEWS の矢印ボタン背景 | 淡いピンク `#f9e6e3` 付近 |
| ヘッダー背景 | ダークグレー `#333` 付近 |

正確な値は Figma を正とする。

### フォント

| 用途 | フォント | 太さ |
|---|---|---|
| 本文（基本） | M PLUS 2 | 400（太字は 600） |
| ボタン | M PLUS 2 | 600 |
| 見出し（英字） | Archivo Black | 400 |
| 見出しに重ねる筆記体 | Whisper | 400 |

- いずれも Google Fonts から読み込む。
- 本文、日付、ボタン文字は字間を広め（`tracking-widest` 程度）にとる。

### ヘッダー

- **PC：画面右端に常に固定**（縦長のバー）。
- **スマホ：画面下に常に固定**（横長のバー）。
- デザイン上は SONGS にしか描かれていないが、**全セクションで表示する**。
- デザインで確認できる要素
  - 再生／一時停止ボタン（バー中央）
  - ミュート切り替えボタン（バー下部、ベル＋斜線のアイコン）
- アイコンは FontAwesome。

### 音楽（BGM）

- オープニングで「音あり／音なし」を選ばせる。
  - ブラウザの自動再生制限があるため、ここでのクリックを再生開始のきっかけにする。
- ヘッダーからいつでもオン／オフを切り替えられる。
- 選んだ状態は `localStorage` に保存し、次回アクセス時の初期値に使う（読み書きは try/catch で囲む）。
- 音源ファイルの置き場所とファイル名は**要確認**。

### アイコン

- 基本は FontAwesome（導入方法は importmap で `@fortawesome/fontawesome-free` を pin するか CDN かを決める）。
- **SONGS の配信先アイコン（YouTube、ニコニコ、Spotify、Apple Music、Amazon Music、AWA）はすべて画像**。`app/assets/images/songs/` に用意済み。FontAwesome は使わない。
- DIORAMA の SNS アイコンは、ニコニコ、note のみ画像（用意済み）。X、YouTube は FontAwesome。
- ト音記号（料金表ボタン）は FontAwesome Free に無い可能性が高いので、実装前に確認する。無ければ画像を用意してもらう。

### 画像

- すべて `app/assets/images/<画面名>/` に用意済み。
  - `app/assets/images/songs/`
  - `app/assets/images/diorama/`
  - `app/assets/images/news/`
  - `app/assets/images/contact/`
- `diorama_logo.png`、背景の額縁パーツ、カードの紙テクスチャなどの所在は、実ファイルを確認して追記する。
- CMS から登録される画像・音源はすべて Active Storage で扱う。

---

## セクション別仕様

### 共通：見出し

| セクション | 見出しのデザイン |
|---|---|
| SONGS | Archivo Black「SONGS」を左上がりに傾ける。下に Whisper「Songs.」（ベージュ）が重なる |
| DIORAMA | Archivo Black「DIORAMA」。文字の中が斜線ハッチングで、同じ形の袋文字（アウトライン）が右下にずれて重なる。傾けない |
| NEWS | Archivo Black「NEWS」を左上がりに傾ける。下に Whisper「News.」（ベージュ）が重なる |
| CONTACT | Archivo Black「CONTACT」。下に Whisper「Contact.」が**袋文字**で重なる。傾けない |

---

### 1. SONGS

**レイアウト**

- 見出しは左上。
- 背景に淡い水色の五線譜（細い横線のまとまり）が、額縁の内側に長方形で描かれている。
- 楽曲カードが横一列に並ぶ。カードは上下に少しずつずらして配置（交互に段違い）。

**楽曲カード**

- 古い紙のような質感（ベージュ系の紙テクスチャ）。
- 上から順に
  1. ジャケット画像（正方形）
  2. 曲名（長い場合ははみ出さず省略）
  3. 配信先アイコン（URL が登録されているものだけ表示）：YouTube、ニコニコ、Spotify、Apple Music、Amazon Music、AWA の順。画像は `app/assets/images/songs/`。
- カードの外、右下に `xxxx.xx.xx Release`（リリース日）。

**挙動**

- 表示件数は**4件まで**、**登録順**。公開状態のものだけ表示する。
- 縦スクロールの入力を横スクロールに変換して、カードを横に送る。
- 一番右までスクロールすると「もっと見る」ボタンが現れる。
- そこからさらにスクロールすると、次のセクション（DIORAMA）がふわっと出てくる。
- 「もっと見る」で全楽曲の一覧を表示する（一覧画面の形式は**要確認**：別ページかモーダルか）。

**データ**：`Song`（「CMS」の章を参照）。楽曲の「詳細」はカードには出さず、全楽曲一覧で表示する想定（**要確認**）。

---

### 2. DIORAMA（プロフィール）

**レイアウト**

- 中央に薄い白の半透明カード（**角丸なし**）。カードにはうっすら五線譜（細い横線）が入る。
- 見出しはカードの左上からはみ出す位置。
- 右上に SNS アイコン（デザインでは X、YouTube、ニコニコ、note）。
- 左にプロフィール画像。
- 右にプロフィール文（字間広め、行間広め）。
- プロフィール文の下に「料金表・ご依頼について」ボタン（枠線のみのピル型、左端にト音記号が重なる）。
- 区切り線の下に「実績：」と実績の一覧。

**挙動**

- 「料金表・ご依頼について」を押すとモーダルを開く。
- SNS アイコンは外部リンク（`target="_blank" rel="noopener"`）。

- 料金表モーダルには、料金表（Markdown をレンダリングしたもの）と「依頼についての注意点」を表示する。表（table）のスタイルもモーダル内で整える。
- SNS アイコンは URL が登録されているものだけ表示する。

**データ**：`Profile`（「CMS」の章を参照）

---

### 3. NEWS

**レイアウト**

- 中央に薄い白の半透明カード。右上と左下に濃いグレーのL字型の装飾（角のブラケット）がはみ出す。
- 見出しはカード左上からはみ出す位置。
- 左側：イラスト（円形のジオラマ）と「View More →」ボタン（枠線のみのピル型）。
- 右側：ニュース一覧（デザインでは6件）。各行に
  - 日付（`XXXX.XX.XX`）
  - タイトル（例：「○○○○」を公開しました。）
  - 右端に淡いピンクの正方形の矢印ボタン（→）
- 各行は細い横線で区切る。

**挙動**

- 行の矢印（または行全体）を押すと、ページをめくる演出で中央部分にニュース詳細を表示する。
- 詳細から一覧に戻る導線を用意する。
- 「View More」で全ニュースの一覧を表示する（形式は**要確認**）。
- 一覧は公開日の新しい順。公開状態のものだけ表示する。

**データ**：`News`（「CMS」の章を参照）

---

### 4. CONTACT

**レイアウト**

- 中央に半透明カード（**角丸なし**）。白い細い線で罫線（グリッド）が引かれたデザイン。
- 左上にインク瓶、右下に羽ペンの画像（カードからはみ出して重なる）。
- 見出しはカード上部中央。
- フォーム項目（縦並び、入力欄は淡いグレーの角なしボックス）
  1. 企業名
  2. お名前
  3. メールアドレス
  4. お問い合わせ内容（複数行）
- 「送信」ボタン（細い枠線、右に紙飛行機アイコン）。

**挙動**

- 送信内容は DB に保存し、CMS で確認できるようにする。
- 入力ラベルはプレースホルダーとして表示されているが、アクセシビリティのため `label` 要素も付ける（視覚的に隠してよい）。
- 必須項目、送信後の表示（完了メッセージ／メール通知の有無）は**要確認**。
- 送信は Turbo で行い、ページ全体を再読み込みしない。

**データ**：`Contact`（「CMS」の章を参照）

### 共通：ロゴと BGM のフォールバック

- オープニングのロゴは、CMS で登録されていればそれを、未登録なら `diorama_logo.png`（assets）を表示する。
- BGM は、CMS で登録されていればそれを、未登録なら assets の音源を再生する。
- 判定はヘルパー（例：`site_logo_source`、`site_bgm_source`）にまとめ、ビューで分岐を書かない。

---

## レスポンシブ

- PC のデザイン（1920×1080 想定）を基準に作る。
- スマホではヘッダーを下固定にする。
- それ以外のスマホ版レイアウト（SONGS の横スクロール、DIORAMA の画像と本文の並び、インク瓶と羽ペンの扱いなど）は**要確認**。

---

## CMS（管理画面）

### 基本方針

- パスは `/admin` 配下。コントローラは `Admin::` 名前空間にまとめ、`Admin::BaseController` で認証を必須にする。
- 認証は Rails 8 の認証ジェネレータ（`bin/rails generate authentication`）を使う。Gemfile の `bcrypt` のコメントアウトを外す。
- 管理者アカウントは seeds（または rails console）で作成する。公開側にサインアップ画面は作らない。
- 画像・音源はすべて Active Storage（`image_processing` と `libvips` は導入済み）。
- 管理画面用のレイアウト `layouts/admin.html.slim` を用意する（左サイドバーにメニュー、右にコンテンツ。スマホではメニューを折りたたむ）。公開側のフォントや額縁装飾、BGM は管理画面に持ち込まない。

### デザイン

既存の別案件の CMS（Slim + Tailwind）に近い見た目で作る。

| 要素 | クラスの目安 |
|---|---|
| ページ背景 | `bg-gray-50` |
| ページ見出し | `h1.text-2xl.font-bold.text-gray-800.mb-6` |
| カード / テーブルの外枠 | `.bg-white.rounded-xl.shadow-sm.border.border-gray-200` |
| テーブル見出し行 | `tr.bg-gray-50` / `th.px-5.py-3.text-left.text-xs.font-medium.text-gray-500.uppercase` |
| テーブル行 | `tr.border-t.border-gray-100.hover:bg-gray-50`（行クリックで編集画面へ） |
| 入力欄 | `w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none` |
| ラベル | `label.block.text-sm.font-medium.text-gray-700.mb-1`（必須は末尾に ` *`） |
| ファイル選択 | `file:` 系ユーティリティで `file:bg-indigo-50 file:text-indigo-700` |
| 主ボタン | `px-6 py-2.5 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700` |
| 副ボタン（キャンセル） | `px-6 py-2.5 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200` |
| ステータスバッジ | `span.px-2.py-0.5.rounded.text-xs` ＋ 公開 `bg-green-100 text-green-700` / 下書き `bg-gray-100 text-gray-600` / 未対応 `bg-amber-100 text-amber-700` |
| エラー表示 | `.bg-red-50.border.border-red-200.rounded-lg.p-4` に `full_messages` を箇条書き |
| アイコン | FontAwesome（`fa-solid` / `fa-regular`） |
| 操作アイコン | 編集 `fa-pen`、削除 `fa-trash`（`turbo_confirm: "本当に削除しますか？"`） |

- フォームは `form_with model: [:admin, record]` で、`_form.html.slim` を new / edit で共有する。
- 2カラムの項目は `.grid.grid-cols-1.md:grid-cols-2.gap-6` で並べる。
- 画像を登録済みなら、ファイル選択の下にプレビュー（`image_tag`）を出す。音源は `audio controls` でプレビューする。
- 一覧のテーブルは `overflow-x-auto` で包み、狭い画面では重要でない列を `hidden sm:table-cell` で隠す。

### 画面構成

| メニュー | パス | 内容 |
|---|---|---|
| ダッシュボード | `/admin` | 件数カード（公開中の楽曲、公開中のニュース、下書き合計、未対応のお問い合わせ） |
| サイト設定 | `/admin/site_setting` | ロゴ、BGM（単一レコード。show / edit / update のみ） |
| 楽曲 | `/admin/songs` | 一覧、新規、編集、削除 |
| プロフィール | `/admin/profile` | 単一レコード。show / edit / update のみ |
| ニュース | `/admin/news` | 一覧、新規、編集、削除 |
| お問い合わせ | `/admin/contacts` | 一覧、詳細、対応済みの切り替え、削除（新規・編集はなし） |

- 単一レコード（`SiteSetting`、`Profile`）は `resource`（単数形）でルーティングし、`first_or_create!` 相当で取得する。

### モデル

#### SiteSetting（単一レコード）

| 項目 | 型 | 備考 |
|---|---|---|
| logo | Active Storage（画像） | 未登録なら assets の `diorama_logo.png` |
| bgm | Active Storage（音声） | 未登録なら assets の音源 |

#### Song（楽曲）

| 項目 | 型 | 備考 |
|---|---|---|
| title | string | 必須 |
| description | text | 詳細 |
| released_on | date | リリース日 |
| jacket | Active Storage（画像） | 正方形推奨 |
| youtube_url | string | 任意。未登録なら公開側で非表示 |
| niconico_url | string | 同上 |
| apple_music_url | string | 同上 |
| amazon_music_url | string | 同上 |
| awa_url | string | 同上 |
| spotify_url | string | 同上 |
| status | integer（enum） | `draft`（下書き）/ `published`（公開）。初期値 `draft` |

- URL はすべて `http(s)://` 形式のみ許可する。
- 配信先は定数（例：`Song::STREAMING_SERVICES = [{ key: :youtube_url, name: "YouTube", icon: "songs/youtube.png" }, ...]`）にまとめ、フォームと公開側のアイコン表示の両方でこれを回す。並び順は YouTube、ニコニコ、Spotify、Apple Music、Amazon Music、AWA。アイコンのファイル名は `app/assets/images/songs/` の実ファイルに合わせる。
- 公開側の並び順は登録順（`created_at` 昇順）。

#### Profile（単一レコード）

| 項目 | 型 | 備考 |
|---|---|---|
| body | text | プロフィール文 |
| image | Active Storage（画像） | プロフィール画像 |
| price_table | text | 料金表。**Markdown** で入力 |
| request_notes | text | 依頼についての注意点（料金表モーダルに表示） |
| achievements | text | 実績。1行1件で入力し、公開側では行ごとに表示 |
| x_url | string | 任意。未登録なら非表示 |
| youtube_url | string | 同上 |
| niconico_url | string | 同上 |
| note_url | string | 同上 |

#### News（ニュース）

| 項目 | 型 | 備考 |
|---|---|---|
| title | string | 必須 |
| body | text | NEWS 詳細 |
| published_on | date | 公開日。必須 |
| status | integer（enum） | `draft` / `published`。初期値 `draft` |

- モデル名は `News`。複数形も `news` になるので、ルーティングは `resources :news` で `admin_news_index_path` / `admin_news_path` を使う。

#### Contact（お問い合わせ）

| 項目 | 型 | 備考 |
|---|---|---|
| company_name | string | 企業名。任意 |
| name | string | お名前。必須 |
| email | string | メールアドレス。必須、形式チェック |
| body | text | お問い合わせ内容。必須 |
| responded | boolean | 対応済みフラグ。初期値 `false`（CMS で切り替え） |

- 公開側の CONTACT フォームから作成する。管理画面からは作成・編集しない。
- 一覧は新しい順。未対応はバッジで目立たせる。

### 下書きと公開

- `Song` と `News` は `status` で下書き／公開を切り替える。
- フォームの送信ボタンは「下書き保存」と「公開する」の2つにする（`f.submit` に `name: "status"` と値を持たせる）。
- 公開側では `published` スコープ（例：`scope :published, -> { where(status: :published) }`）を必ず通す。
- `News` は公開日が未来のものも公開側に出さない（予約公開の扱い）。

### 本文の表示

- **料金表（`Profile#price_table`）のみ Markdown**。
  - `redcarpet` gem でレンダリングする。表を使うので `tables: true` を有効にする（ほか `autolink`、`strikethrough` 程度）。
  - レンダラは `filter_html: true` で生の HTML を無効化し、出力をさらに `sanitize` に通す。
  - 変換はヘルパー（例：`markdown(text)`）にまとめる。
  - CMS の入力欄には「Markdown 対応」の注記を出す（サンプル同様 `span.text-xs.text-gray-400`）。プレビュー機能は必須ではない。
- それ以外（`Song#description`、`Profile#body`、`Profile#request_notes`、`Profile#achievements`、`News#body`）はプレーンテキスト。公開側では `simple_format` で改行を反映する。HTML は入力させない。

---

## 未確定事項（後で追記）

- BGM のフォールバック音源のファイル名と置き場所（例：`app/assets/audio/`）
- 「もっと見る」「View More」の遷移先の形式
- お問い合わせ送信後の挙動（完了メッセージ／メール通知の有無）
- スマホ版のレイアウト詳細
- ヘッダーに再生／ミュート以外の項目（セクションへのナビゲーションなど）を入れるか
- 管理者のアカウントを複数作るか、権限（管理者／編集者）や承認フローを入れるか
---

## 実装メモ（初回実装時に決めたこと）

- 画像の実際の置き場所：プロフィール用は `app/assets/images/profile/`（`diorama/` ではない）。
- オープニングのロゴと BGM のフォールバックは `public/diorama_logo.png` と `public/bgm_16bit.wav`（元の `bgm.wav` は 32bit float で再生できないブラウザがあるため 16bit PCM に変換したもの）（`ApplicationHelper#site_logo_source` / `#site_bgm_source`）。
- 背景の額縁と紙の質感は画像を使わず CSS で描画（`.site-frame` / `.frame-ring-*` / `.paper`）。四隅のスカラップ線は `scallop_frame_controller.js` で SVG を描く。
- FontAwesome は CDN（cdnjs, 6.7.2）の CSS を `shared/_font_awesome` で読み込む。
- ト音記号は FontAwesome Free に無いため、Google Fonts の Noto Music を U+1D11E だけサブセットで読み込んで文字で表示（画像が用意されたら差し替える）。
- 「もっと見る」・楽曲カードのクリック：SONGS のカード上に NEWS と同じ白いカード（Turbo Frame `songs_panel`）を開き、全楽曲一覧／楽曲詳細を表示。
- 「View More」：NEWS カード中央の Turbo Frame `news_panel` に全件一覧を、ページめくり演出で表示。`/songs` `/news` を直接開いた場合はトップへリダイレクト。
- ヘッダーは中央の2本線でメニュー（ドロワー）を右から開く。BGM はミュートボタンのみ（解除時に再生開始）。
- 中央のカードは FHD で 1450×670 の比率（`.stage-card`）。五線譜はカードの高さに6段（`.staff-lines`）。
- お問い合わせ：企業名以外を必須。送信後はフォームを完了メッセージに差し替える。メール通知は未実装。
- スマホ：PC と同じセクション切り替え（スワイプ）で、余白とサイズだけ調整。
- 管理画面は `/admin`。開発者は `.env` の `ADMIN_USER_ID` / `ADMIN_USER_PASS` でログイン（開発・テスト環境では `config/initializers/dotenv.rb` が `.env` を読み込む。パスワードは .env で管理し画面からは変更不可）。それ以外のユーザーは「パスワード変更」画面で自分のパスワードを変更できる（8文字以上）。seeds でも同じ値で管理者を作成できる：`bin/rails db:seed`。`SEED_SAMPLE=1` を付けると開発用サンプルデータも入る。
- SEO：メタ情報・OGP・構造化データ（JSON-LD）は `SeoHelper`。`/robots.txt` と `/sitemap.xml` は `SeoController` で動的に返す（`public/robots.txt` は置かない）。
