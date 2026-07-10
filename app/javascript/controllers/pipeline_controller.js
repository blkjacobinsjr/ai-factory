import { Controller } from "@hotwired/stimulus"

// Animates the homepage pipeline strip: lights each step in order
// (is-active = running now, is-done = finished), prints the active step's
// data-detail caption, then rests and loops. All visuals live in CSS —
// this file is only a timer flipping classes, which is why it stays small.
// If it breaks, the strip still renders fully via ERB; it just won't move.
export default class extends Controller {
  static targets = ["step", "detail"]

  STEP_MS = 1400   // how long each step "runs"
  REST_MS = 3500   // pause on the finished strip before looping

  connect() { this.replay() }

  // Also the replay button's action. Restarting = reset everything, go again.
  replay() {
    this.stop()
    this.index = -1
    this.stepTargets.forEach(s => s.classList.remove("is-active", "is-done"))
    this.syncConnectors()
    this.timer = setInterval(() => this.tick(), this.STEP_MS)
    this.tick()
  }

  tick() {
    this.index += 1
    if (this.index >= this.stepTargets.length) {
      // Strip finished: every step goes green (including the last one —
      // without this, "merge" pulses forever while the caption claims the
      // ticket merged; review finding F2). Then rest and loop.
      this.stop()
      this.stepTargets.forEach(s => {
        s.classList.remove("is-active")
        s.classList.add("is-done")
      })
      this.syncConnectors()
      this.detailTarget.textContent = "ticket merged — back to idle"
      this.timer = setTimeout(() => this.replay(), this.REST_MS)
      return
    }
    this.stepTargets.forEach((step, i) => {
      step.classList.toggle("is-active", i === this.index)
      step.classList.toggle("is-done", i < this.index)
    })
    this.detailTarget.textContent = this.stepTargets[this.index].dataset.detail
    this.syncConnectors()
  }

  // A connector fills when the step BEFORE it is done or running.
  // Connectors aren't targets (they're decoration); we find them by class.
  syncConnectors() {
    this.element.querySelectorAll(".connector").forEach((c, i) => {
      const before = this.stepTargets[i]
      c.classList.toggle("is-done",
        before.classList.contains("is-done") || before.classList.contains("is-active"))
    })
  }

  // Without this, navigating away and back with Turbo would stack timers.
  disconnect() { this.stop() }

  stop() {
    clearInterval(this.timer)
    clearTimeout(this.timer)
  }
}
