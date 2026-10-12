import { Controller } from "@hotwired/stimulus"

// 管理画面のスマホ用メニューの開閉
export default class extends Controller {
  static targets = [ "menu", "button" ]

  toggle() {
    const opened = this.menuTarget.classList.toggle("hidden") === false
    this.buttonTarget.setAttribute("aria-expanded", String(opened))
  }
}
