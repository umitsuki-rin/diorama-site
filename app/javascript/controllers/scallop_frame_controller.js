import { Controller } from "@hotwired/stimulus"

// 四隅が内側に丸くえぐれた（スカラップコーナーの）線を、要素のサイズに合わせて描く
export default class extends Controller {
  static targets = [ "path" ]
  static values = { radius: { type: Number, default: 24 } }

  connect() {
    this.observer = new ResizeObserver(() => this.draw())
    this.observer.observe(this.element)
    this.draw()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  draw() {
    const { width: w, height: h } = this.element.getBoundingClientRect()
    if (w === 0 || h === 0) return

    const r = Math.min(this.radiusValue, w / 4, h / 4)
    const arc = (x, y) => `A ${r} ${r} 0 0 0 ${x} ${y}`

    this.pathTarget.setAttribute("d", [
      `M ${r} 0`, `H ${w - r}`, arc(w, r),
      `V ${h - r}`, arc(w - r, h),
      `H ${r}`, arc(0, h - r),
      `V ${r}`, arc(r, 0), "Z"
    ].join(" "))
  }
}
