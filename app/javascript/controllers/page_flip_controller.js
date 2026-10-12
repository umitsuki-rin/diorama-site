import { Controller } from "@hotwired/stimulus"
import { clearAnimations, floatIn, hide, prefersReducedMotion, turnPageAway, turnPageBack } from "lib/motion"

// NEWS カード中央（Turbo Frame）の中身を、ページをめくる演出で差し替える。
// リンクの data-flip="forward" / "back" で、めくる向きを決める（指定のない読み込みは演出なし）
export default class extends Controller {
  static targets = [ "frame" ]

  remember(event) {
    const link = event.target.closest("a[data-flip]")
    if (link) this.direction = link.dataset.flip
  }

  async beforeRender(event) {
    if (prefersReducedMotion() || !this.direction) return

    event.preventDefault()
    if (this.direction === "back") {
      await hide(this.frameTarget)
    } else {
      await turnPageAway(this.frameTarget)
    }
    event.detail.resume()
  }

  async afterRender() {
    const direction = this.direction
    this.direction = null

    if (direction && !prefersReducedMotion()) {
      clearAnimations(this.frameTarget)
      if (direction === "back") {
        await turnPageBack(this.frameTarget)
      } else {
        await floatIn(this.frameTarget)
      }
      clearAnimations(this.frameTarget)
    }

    this.frameTarget.querySelector("[data-page-flip-focus]")?.focus({ preventScroll: true })
    this.frameTarget.closest(".overflow-y-auto")?.scrollTo({ top: 0 })
  }
}
