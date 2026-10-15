require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  VALID = { name: "山田", email: "yamada@example.com", body: "依頼です" }.freeze
  FRAME = { "Turbo-Frame" => "contact_form" }.freeze

  # フォームを表示したときのトークンを取り出す
  def form_token
    get root_path
    css_select("input[name=form_token]").first["value"]
  end

  test "お問い合わせを保存して完了メッセージを返す" do
    token = form_token
    travel 5.seconds

    assert_difference -> { Contact.count } do
      post contacts_path, params: { contact: VALID.merge(name_kana: ""), form_token: token }, headers: FRAME
    end
    assert_response :success
    assert_match "送信が完了しました", response.body
    assert_not Contact.last.responded?
  end

  test "入力エラーなら 422 でフォームを返す" do
    token = form_token
    travel 5.seconds

    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: { name: "", email: "bad", body: "" }, form_token: token }, headers: FRAME
    end
    assert_response :unprocessable_entity
    assert_match "お名前を入力してください", response.body
    assert_select "input[name=form_token]"
  end

  test "ハニーポット（フリガナ）に入力があれば、完了画面を返すが保存しない" do
    token = form_token
    travel 5.seconds

    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: VALID.merge(name_kana: "ヤマダ"), form_token: token }, headers: FRAME
    end
    assert_match "送信が完了しました", response.body
  end

  test "表示から送信までが速すぎると保存しない" do
    token = form_token

    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: VALID, form_token: token }, headers: FRAME
    end
    assert_match "送信が完了しました", response.body
  end

  test "トークンが無い・改ざんされていると保存しない" do
    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: VALID }, headers: FRAME
      post contacts_path, params: { contact: VALID, form_token: "forged" }, headers: FRAME
    end
  end

  test "トークンの期限切れは保存しない" do
    token = form_token
    travel 2.days

    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: VALID, form_token: token }, headers: FRAME
    end
  end
end
