import { Controller } from "@hotwired/stimulus"

// 管理画面の一覧で、行クリックを編集・詳細画面への遷移にする
export default class extends Controller {
  static values = { url: String }

  visit(event) {
    if (event.target.closest("a, button, input, form, label")) return

    window.Turbo.visit(this.urlValue)
  }
}
