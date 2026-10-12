import { Controller } from "@hotwired/stimulus"

// ヘッダーの2本線ボタンで開閉するメニュー
export default class extends Controller {
  static targets = [ "button", "panel", "backdrop" ]

  connect() {
    window.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    window.removeEventListener("keydown", this.closeOnEscape)
  }

  toggle() {
    this.opened ? this.close() : this.open()
  }

  open() {
    this.panelTarget.toggleAttribute("data-open", true)
    this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.setAttribute("aria-label", "メニューを閉じる")
    this.panelTarget.querySelector("button")?.focus({ preventScroll: true })
  }

  close() {
    if (!this.opened) return

    this.panelTarget.toggleAttribute("data-open", false)
    this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "メニューを開く")
  }

  get opened() {
    return this.panelTarget.hasAttribute("data-open")
  }

  closeOnEscape = (event) => {
    if (event.key === "Escape" && this.opened) {
      this.close()
      this.buttonTarget.focus()
    }
  }
}
