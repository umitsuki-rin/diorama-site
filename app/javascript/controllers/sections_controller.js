import { Controller } from "@hotwired/stimulus"
import { PEEL_VISIBLE_DURATION, clearAnimations, floatIn, floatOut, hide, prefersReducedMotion, turnPageAway, turnPageBack } from "lib/motion"

const wait = ms => new Promise(resolve => setTimeout(resolve, ms))

const WHEEL_THRESHOLD = 40
const SWIPE_THRESHOLD = 60
const KEY_STEP = 160
// 切り替え直後やカードの端に達した直後は、慣性スクロールが止まるまで次の切り替えを受け付けない
const IDLE_GAP = 220

// 1ページ構成のセクション切り替え。
// 縦スクロール（ホイール／スワイプ／キー）を受けて、
//   1. SONGS の横スクロール（カード送り）
//   2. セクション内のスクロール可能な領域
//   3. 次／前のセクションへの切り替え
// の順に消費する。
export default class extends Controller {
  static targets = [ "section", "track", "more", "navItem", "prevButton", "nextButton" ]

  connect() {
    this.index = 0
    this.enabled = false
    this.animating = false
    this.lockedUntil = 0
    this.wheelDelta = 0

    this.listeners = [
      [ "wheel", this.onWheel, { passive: false } ],
      [ "touchstart", this.onTouchStart, { passive: true } ],
      [ "touchmove", this.onTouchMove, { passive: false } ],
      [ "touchend", this.onTouchEnd, { passive: true } ],
      [ "keydown", this.onKeydown, {} ]
    ]
    this.listeners.forEach(([ type, listener, options ]) => window.addEventListener(type, listener, options))
    this.trackScrolled()
    this.markCurrent()
  }

  disconnect() {
    this.listeners.forEach(([ type, listener, options ]) => window.removeEventListener(type, listener, options))
  }

  enable() {
    this.enabled = true
    this.trackScrolled()
  }

  // SONGS のカードが一番右まで来たら「もっと見る」を出す
  trackScrolled() {
    if (!this.hasTrackTarget || !this.hasMoreTarget) return

    const visible = this.remaining(this.trackTarget) <= 1
    this.moreTarget.classList.toggle("opacity-0", !visible)
    this.moreTarget.classList.toggle("translate-x-4", !visible)
  }

  // --- 入力 ---------------------------------------------------------------

  onWheel = (event) => {
    if (!this.listening) return

    const delta = this.normalizeWheel(event)
    if (this.isLocked()) {
      event.preventDefault()
      this.lock()
      return
    }

    const result = this.consume(delta, event.target)
    if (result === "native") return

    event.preventDefault()
    if (result === "consumed") {
      this.wheelDelta = 0
      return
    }

    this.wheelDelta += delta
    if (Math.abs(this.wheelDelta) >= WHEEL_THRESHOLD) {
      this.go(Math.sign(this.wheelDelta))
      this.wheelDelta = 0
    }
  }

  onTouchStart = (event) => {
    const touch = event.touches[0]
    this.touch = { x: touch.clientX, y: touch.clientY, lastY: touch.clientY, axis: null, swipe: 0 }
  }

  onTouchMove = (event) => {
    if (!this.listening || !this.touch) return

    const touch = event.touches[0]
    const dx = touch.clientX - this.touch.x
    const dy = touch.clientY - this.touch.y
    // 横方向のスワイプはブラウザの横スクロールに任せる
    this.touch.axis ||= Math.abs(dx) > Math.abs(dy) ? "x" : "y"
    if (this.touch.axis === "x") return

    const delta = this.touch.lastY - touch.clientY
    this.touch.lastY = touch.clientY
    if (this.animating) {
      event.preventDefault()
      return
    }

    const result = this.consume(delta, event.target)
    if (result === "native") return

    event.preventDefault()
    if (result === "edge") this.touch.swipe += delta
  }

  onTouchEnd = () => {
    if (!this.listening || !this.touch) return

    if (Math.abs(this.touch.swipe) >= SWIPE_THRESHOLD && !this.animating) this.go(Math.sign(this.touch.swipe))
    this.touch = null
  }

  onKeydown = (event) => {
    if (!this.listening || event.altKey || event.ctrlKey || event.metaKey) return
    if (event.target.closest("input, textarea, select, [contenteditable]")) return

    const step = { ArrowDown: 1, PageDown: 1, ArrowUp: -1, PageUp: -1, " ": event.shiftKey ? -1 : 1 }[event.key]
    if (!step) return
    if (event.key === " " && event.target.closest("button, a")) return

    if (this.animating) {
      event.preventDefault()
      return
    }

    const result = this.consume(step * KEY_STEP, event.target)
    if (result === "native") return

    event.preventDefault()
    if (result === "edge") this.go(step)
  }

  // --- 判定 ---------------------------------------------------------------

  // モーダル・メニューが開いているとき、または今のセクション内に data-lock-sections がある
  // （SONGS の一覧・詳細、NEWS の全件一覧・詳細）ときは、スクロールでセクションを切り替えない
  get listening() {
    if (!this.enabled || document.querySelector("dialog[open], .drawer-panel[data-open]")) return false
    return !this.currentSection.querySelector("[data-lock-sections]")
  }

  get currentSection() {
    return this.sectionTargets[this.index]
  }

  // "consumed"：こちらで横スクロールした / "native"：ブラウザのスクロールに任せる / "edge"：セクション切り替えの対象
  consume(delta, target) {
    if (delta === 0) return "consumed"

    const section = this.currentSection
    const track = this.trackTargets.find(element => section.contains(element))
    if (track && this.canScroll(track, delta, "x")) {
      track.scrollLeft += delta
      this.trackScrolled()
      // カードが端に達したら、一度手を止めてからでないと次のセクションへ進まない
      if (!this.canScroll(track, delta, "x")) this.lock()
      return "consumed"
    }

    for (let element = target instanceof Element ? target : null; element && element !== section; element = element.parentElement) {
      if (this.canScroll(element, delta, "y")) return "native"
    }
    return "edge"
  }

  canScroll(element, delta, axis) {
    const style = getComputedStyle(element)
    const overflow = axis === "x" ? style.overflowX : style.overflowY
    if (!/(auto|scroll)/.test(overflow)) return false

    if (axis === "x") return delta > 0 ? this.remaining(element) > 1 : element.scrollLeft > 0
    return delta > 0 ? element.scrollHeight - element.clientHeight - element.scrollTop > 1 : element.scrollTop > 0
  }

  remaining(track) {
    return track.scrollWidth - track.clientWidth - track.scrollLeft
  }

  normalizeWheel(event) {
    const raw = Math.abs(event.deltaY) >= Math.abs(event.deltaX) ? event.deltaY : event.deltaX
    if (event.deltaMode === WheelEvent.DOM_DELTA_LINE) return raw * 16
    if (event.deltaMode === WheelEvent.DOM_DELTA_PAGE) return raw * window.innerHeight
    return raw
  }

  lock() {
    this.lockedUntil = performance.now() + IDLE_GAP
  }

  isLocked() {
    return this.animating || performance.now() < this.lockedUntil
  }

  // --- 切り替え -----------------------------------------------------------

  go(step) {
    return this.transitionTo(this.index + step)
  }

  // メニューから任意のセクションへ移動する
  goTo({ params: { index } }) {
    return this.transitionTo(index)
  }

  async transitionTo(to) {
    const from = this.index
    if (this.animating || to === from || to < 0 || to >= this.sectionTargets.length) return

    const step = Math.sign(to - from)
    const outgoing = this.sectionTargets[from]
    const incoming = this.sectionTargets[to]
    // 境界の演出は、後ろ側のセクションに設定したもの（逆方向でも同じ演出を逆再生する）。離れたセクションへはふわっと切り替える
    const effect = Math.abs(to - from) === 1 ? this.sectionTargets[Math.max(from, to)].dataset.effect : "fade"

    this.animating = true
    this.index = to
    this.markCurrent()
    incoming.removeAttribute("inert")
    outgoing.setAttribute("inert", "")
    incoming.classList.add("is-animating")
    outgoing.classList.add("is-animating")
    outgoing.classList.remove("is-revealed")

    // 画像類は、出ていく側はすぐふわっと消し、入ってくる側は切り替えが終わる瞬間にふわっと出す
    const images = this.images(incoming)
    const outImages = this.images(outgoing)
    if (!prefersReducedMotion()) {
      images.forEach(image => image.animate([ { opacity: 0 }, { opacity: 0 } ], { fill: "both", duration: 1 }))
      const revealImages = () => {
        incoming.classList.add("is-revealed")
        return Promise.all(images.map((image, i) => floatIn(image, { delay: i * 60, duration: 600 })))
      }
      if (effect === "flip") {
        await this.flip(outgoing, incoming, step, outImages, revealImages)
      } else {
        await this.fade(outgoing, incoming, step, outImages, revealImages)
      }
    }

    outgoing.classList.remove("is-active", "is-animating")
    incoming.classList.add("is-active", "is-revealed")
    incoming.classList.remove("is-animating")
    incoming.style.zIndex = outgoing.style.zIndex = ""
    clearAnimations(this.animatedParts(outgoing), this.animatedParts(incoming), images, outImages)

    this.animating = false
    this.lock()
    if (incoming === this.sectionTargets[0]) this.trackScrolled()
  }

  // 上下ボタン
  prev() {
    return this.go(-1)
  }

  next() {
    return this.go(1)
  }

  markCurrent() {
    this.navItemTargets.forEach((item, index) => item.setAttribute("aria-current", String(index === this.index)))
    if (this.hasPrevButtonTarget) this.prevButtonTarget.disabled = this.index === 0
    if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = this.index === this.sectionTargets.length - 1
  }

  fade(outgoing, incoming, direction, outImages, revealImages) {
    outImages.forEach(image => hide(image, { duration: 250 }))
    return Promise.all([
      floatOut(outgoing, { direction }),
      floatIn(incoming, { direction, delay: 250, duration: 700 }),
      wait(200).then(revealImages)
    ])
  }

  // 進む：今のカードを右下からめくる → 次の中身と画像がふわっと出る
  // 戻る：今の中身と画像が消える → 前のカードがめくり戻ってくる → 画像がふわっと出る
  // めくっている間、下のページはめくった部分だけを見せ、半透明のカードが重ならないようにする
  async flip(outgoing, incoming, direction, outImages, revealImages) {
    const outPage = this.page(outgoing)
    const inPage = this.page(incoming)
    const inContents = this.contents(incoming)
    const outContents = this.contents(outgoing)
    const hideOutImages = Promise.all(outImages.map(image => hide(image, { duration: 250 })))

    if (direction > 0) {
      outgoing.style.zIndex = "2"
      incoming.style.zIndex = "1"
      inContents.forEach(element => element.animate([ { opacity: 0 }, { opacity: 0 } ], { fill: "both", duration: 1 }))
      const turning = turnPageAway(outPage, { under: inPage })
      // 見た目にめくり終わった時点で、すぐに中身と画像をふわっと出す
      await wait(PEEL_VISIBLE_DURATION)
      // めくり終わりの時点で下のページの切り抜きを外す（カードからはみ出した画像が欠けずにふわっと出るように）
      inPage.getAnimations().forEach(animation => animation.cancel())
      const showContents = Promise.all(inContents.map(element => floatIn(element)))
      // data-reveal-images="after-content" のセクションは、中身が出てから画像をふわっと出す
      if (incoming.dataset.revealImages === "after-content") await showContents
      await Promise.all([ turning, showContents, revealImages(), hideOutImages ])
    } else {
      outgoing.style.zIndex = "1"
      incoming.style.zIndex = "2"
      // めくり戻すまで前のページは見せない
      inPage.animate([ { clipPath: "inset(0 100% 100% 0)" }, { clipPath: "inset(0 100% 100% 0)" } ], { fill: "both", duration: 1 })
      await Promise.all([ ...outContents.map(element => hide(element)), hideOutImages ])
      const turning = turnPageBack(inPage, { under: outPage })
      await wait(PEEL_VISIBLE_DURATION)
      await Promise.all([ turning, revealImages() ])
    }
  }

  page(section) {
    return section.querySelector("[data-flip-page]") || section
  }

  contents(section) {
    return Array.from(section.querySelectorAll("[data-flip-content]"))
  }

  images(section) {
    return Array.from(section.querySelectorAll("[data-flip-image]"))
  }

  animatedParts(section) {
    return [ section, this.page(section), ...this.contents(section) ]
  }
}
