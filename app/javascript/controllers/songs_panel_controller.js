import { Controller } from "@hotwired/stimulus"

// SONGS の全楽曲一覧・楽曲詳細のパネルを開閉する。
// 開いている間は data-open と data-lock-sections を付け、スクロールでのセクション切り替えを止める
export default class extends Controller {
  static targets = [ "panel", "cards" ]

  connect() {
    window.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    window.removeEventListener("keydown", this.closeOnEscape)
  }

  open() {
    this.panelTarget.toggleAttribute("data-open", true)
    this.panelTarget.toggleAttribute("data-lock-sections", true)
    this.panelTarget.classList.remove("opacity-0", "invisible")
    this.cardsTarget.classList.add("opacity-0", "pointer-events-none")
  }

  close() {
    this.panelTarget.toggleAttribute("data-open", false)
    this.panelTarget.toggleAttribute("data-lock-sections", false)
    this.panelTarget.classList.add("opacity-0", "invisible")
    this.cardsTarget.classList.remove("opacity-0", "pointer-events-none")

    // 同じ楽曲を開き直したときも読み込み直すよう、中身と src を消しておく
    const frame = this.panelTarget.querySelector("turbo-frame")
    frame.removeAttribute("src")
    frame.innerHTML = '<p class="py-10 text-center tracking-widest">読み込み中…</p>'
  }

  closeOnEscape = (event) => {
    if (event.key === "Escape" && this.panelTarget.hasAttribute("data-open")) this.close()
  }
}
