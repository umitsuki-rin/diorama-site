require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "お問い合わせを保存して完了メッセージを返す" do
    assert_difference -> { Contact.count } do
      post contacts_path, params: { contact: { name: "山田", email: "yamada@example.com", body: "依頼です" } }, headers: { "Turbo-Frame" => "contact_form" }
    end
    assert_response :success
    assert_match "送信が完了しました", response.body
    assert_not Contact.last.responded?
  end

  test "入力エラーなら 422 でフォームを返す" do
    assert_no_difference -> { Contact.count } do
      post contacts_path, params: { contact: { name: "", email: "bad", body: "" } }, headers: { "Turbo-Frame" => "contact_form" }
    end
    assert_response :unprocessable_entity
    assert_match "お名前を入力してください", response.body
  end
end
