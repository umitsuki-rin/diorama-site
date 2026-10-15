import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion } from "lib/motion"

// ロゴマークでトップに戻ったとき、ヘッダーの裏から猫がひょっこり顔を出して、すっと戻る
const STAY = 900

export default class extends Controller {
  static targets = [ "cat" ]

  show() {
    if (prefersReducedMotion()) return

    clearTimeout(this.timer)
    this.catTarget.toggleAttribute("data-peeking", true)
    this.timer = setTimeout(() => this.catTarget.toggleAttribute("data-peeking", false), STAY)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
