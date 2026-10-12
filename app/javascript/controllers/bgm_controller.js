import { Controller } from "@hotwired/stimulus"
import { hide, prefersReducedMotion } from "lib/motion"

const STORAGE_KEY = "diorama:sound"

// BGM の再生／ミュートと、オープニングでの音あり・音なしの選択
export default class extends Controller {
  static targets = [ "audio", "opening", "onChoice", "offChoice", "muteButton", "muteIcon" ]

  connect() {
    this.audioTarget.volume = 0.6
    this.audioTarget.addEventListener("play", this.render)
    this.audioTarget.addEventListener("pause", this.render)
    this.audioTarget.addEventListener("volumechange", this.render)

    // 前回の選択を初期値としてフォーカスしておく
    const preferred = this.loadPreference() === "off" ? this.offChoiceTarget : this.onChoiceTarget
    preferred.focus({ preventScroll: true })
    this.render()
  }

  disconnect() {
    this.audioTarget.removeEventListener("play", this.render)
    this.audioTarget.removeEventListener("pause", this.render)
    this.audioTarget.removeEventListener("volumechange", this.render)
  }

  // オープニングのボタン。このクリックを自動再生制限の解除に使う
  async choose({ params: { sound } }) {
    if (sound === "on") {
      this.audioTarget.muted = false
      this.play()
    } else {
      // 音なし：再生しない
      this.wantsPlay = false
      this.audioTarget.muted = true
      this.audioTarget.pause()
    }
    this.savePreference()

    if (!prefersReducedMotion()) await hide(this.openingTarget, { duration: 700 })
    this.openingTarget.hidden = true
    this.dispatch("opened")
  }

  // ミュート解除時に止まっていれば再生も始める
  toggleMute() {
    const muted = this.soundOn
    this.audioTarget.muted = muted
    if (muted) {
      this.wantsPlay = false
      this.audioTarget.pause()
    } else if (this.audioTarget.paused) {
      this.play()
    }
    this.savePreference()
  }

  // 再生できなかった場合（読み込み前・ブラウザの自動再生制限など）は、次のクリックやキー操作で再試行する
  play() {
    this.wantsPlay = true
    this.audioTarget.play().catch(() => {
      this.render()
      this.retryOnNextInteraction()
    })
  }

  retryOnNextInteraction() {
    if (this.retrying) return
    this.retrying = true

    const retry = () => {
      this.retrying = false
      window.removeEventListener("pointerdown", retry, true)
      window.removeEventListener("keydown", retry, true)
      if (this.wantsPlay && !this.audioTarget.muted && this.audioTarget.paused) this.play()
    }
    window.addEventListener("pointerdown", retry, true)
    window.addEventListener("keydown", retry, true)
  }

  render = () => {
    const muted = !this.soundOn

    this.muteIconTarget.classList.toggle("fa-bell-slash", muted)
    this.muteIconTarget.classList.toggle("fa-bell", !muted)
    this.muteButtonTarget.setAttribute("aria-pressed", String(muted))
    this.muteButtonTarget.setAttribute("aria-label", muted ? "ミュートを解除" : "ミュートする")
  }

  get soundOn() {
    return !this.audioTarget.muted && !this.audioTarget.paused
  }

  loadPreference() {
    try {
      return window.localStorage.getItem(STORAGE_KEY)
    } catch {
      return null
    }
  }

  savePreference() {
    // play() 直後は paused が false になっているので、その時点の状態を保存する
    try {
      window.localStorage.setItem(STORAGE_KEY, this.soundOn ? "on" : "off")
    } catch {
      // ストレージが使えない環境では保存しない
    }
  }
}
