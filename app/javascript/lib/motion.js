// セクション切り替えとニュースのページめくりで共有する演出

const EASE_OUT = "cubic-bezier(0.22, 1, 0.36, 1)"

export function prefersReducedMotion() {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches
}

function run(element, keyframes, options) {
  if (!element) return Promise.resolve()
  return element.animate(keyframes, { fill: "both", ...options }).finished.catch(() => {})
}

// fill: "both" で残したスタイルを片付ける
export function clearAnimations(...elements) {
  elements.flat().filter(Boolean).forEach(element => {
    element.getAnimations().forEach(animation => animation.cancel())
  })
}

// ふわっと（フェード＋わずかな移動）表示する
export function floatIn(element, { direction = 1, delay = 0, duration = 600 } = {}) {
  return run(element, [
    { opacity: 0, transform: `translateY(${24 * direction}px)` },
    { opacity: 1, transform: "translateY(0)" }
  ], { duration, delay, easing: EASE_OUT })
}

export function floatOut(element, { direction = 1, duration = 450 } = {}) {
  return run(element, [
    { opacity: 1, transform: "translateY(0)" },
    { opacity: 0, transform: `translateY(${-24 * direction}px)` }
  ], { duration, easing: EASE_OUT })
}

// 右下の角から左上へ、ページを柔らかくめくる。
// 残りのページを斜めの切り口で clip-path し、切り口に沿って折り返しの陰影（.page-curl）を動かす
const PEEL_STEPS = 24
// カードからはみ出した見出しや画像も含めるため、めくる範囲を上下左右に広げる
const PEEL_MARGIN = 0.2

// t：広げた範囲での切り口の位置（x + y = t、0〜1 で正規化）。2 で全体が残り、0 で何も残らない
function peelPolygon(t) {
  const scale = value => (-PEEL_MARGIN + value * (1 + 2 * PEEL_MARGIN)) * 100
  const point = (x, y) => `${scale(x).toFixed(2)}% ${scale(y).toFixed(2)}%`
  if (t >= 1) return `polygon(${point(0, 0)}, ${point(1, 0)}, ${point(1, t - 1)}, ${point(t - 1, 1)}, ${point(0, 1)})`
  return `polygon(${point(0, 0)}, ${point(t, 0)}, ${point(t, 0)}, ${point(0, t)}, ${point(0, t)})`
}

// めくった部分（x + y > t）。下のページはここだけ見せ、上のページと重ならないようにする
function underPolygon(t) {
  const scale = value => (-PEEL_MARGIN + value * (1 + 2 * PEEL_MARGIN)) * 100
  const point = (x, y) => `${scale(x).toFixed(2)}% ${scale(y).toFixed(2)}%`
  if (t >= 1) return `polygon(${point(1, t - 1)}, ${point(1, t - 1)}, ${point(1, 1)}, ${point(t - 1, 1)}, ${point(t - 1, 1)})`
  return `polygon(${point(t, 0)}, ${point(1, 0)}, ${point(1, 1)}, ${point(0, 1)}, ${point(0, t)})`
}

function peelFrames(from, to, polygon = peelPolygon) {
  return Array.from({ length: PEEL_STEPS + 1 }, (_, i) => {
    const t = from + (to - from) * (i / PEEL_STEPS)
    return { clipPath: polygon(t) }
  })
}

function curlFrames(from, to) {
  // linear-gradient(to top left) の位置 p と、要素の座標での切り口 x + y = s の関係は p = 1 - s / 2
  const position = t => (1 - (t * (1 + 2 * PEEL_MARGIN) - 2 * PEEL_MARGIN) / 2) * 100
  return [ { "--curl": `${position(from)}%` }, { "--curl": `${position(to)}%` } ]
}

const PEEL_DURATION = 1300
// イージングの終わりは切り口がカードの外を通るだけなので、見た目にはこの時点でめくり終わっている
export const PEEL_VISIBLE_DURATION = PEEL_DURATION * 0.68
const PEEL_EASING = "cubic-bezier(0.4, 0, 0.25, 1)"
// 切り口が実際にカード（とはみ出した見出し・画像）の上を通る範囲
const PEEL_START = 1.9
const PEEL_END = 0

async function peel(element, from, to, { duration = PEEL_DURATION, under = null } = {}) {
  if (!element) return

  const options = { duration, easing: PEEL_EASING, fill: "both" }
  // 下のページの切り抜きは途中で解除されることがある（中の画像を早めに見せるとき）
  const underAnimation = under?.animate(peelFrames(from, to, underPolygon), options).finished.catch(() => {})

  const curl = document.createElement("div")
  curl.className = "page-curl"
  element.append(curl)

  await Promise.all([
    element.animate(peelFrames(from, to), options).finished,
    curl.animate(curlFrames(from, to), options).finished,
    underAnimation
  ]).catch(() => {})
  curl.remove()
}

// めくって取り除く（options.under：下にあるページ。めくった部分だけを見せる）
export function turnPageAway(element, options) {
  return peel(element, PEEL_START, PEEL_END, options)
}

// めくったページを戻す（turnPageAway の逆再生）
export function turnPageBack(element, options) {
  return peel(element, PEEL_END, PEEL_START, options)
}

export function hide(element, { duration = 300 } = {}) {
  return run(element, [ { opacity: 1 }, { opacity: 0 } ], { duration, easing: "ease-out" })
}
