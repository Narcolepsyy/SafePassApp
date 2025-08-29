import { Controller } from "@hotwired/stimulus"

// data-controller="password-strength"
// data-password-strength-url-value="/password_strength"
// Targets: input, status, meter
export default class extends Controller {
  static values = {
    url: { type: String, default: "/password_strength" },
    debounce: { type: Number, default: 300 }
  }
  static targets = ["input", "status", "meter"]

  connect() {
    this._timer = null
  }

  disconnect() {
    if (this._timer) clearTimeout(this._timer)
  }

  onInput() {
    if (!this.hasInputTarget) return
    const pwd = this.inputTarget.value
    if (this._timer) clearTimeout(this._timer)
    this._timer = setTimeout(() => this.check(pwd), this.debounceValue)
    this.renderPending()
  }

  async check(password) {
    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify({ password })
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()
      this.renderResult(data)
    } catch (e) {
      this.renderError(e)
    }
  }

  renderPending() {
    this._setStatus("Checking…", "secondary")
    this._setMeter(10)
  }

  renderResult(data) {
    if (!data) return this.renderError()
    const ok = !!data.ok
    const label = (data.label || "").toString()
    const score = Math.round(((data.score || 0) * 100))
    this._setMeter(score)
    if (ok) {
      this._setStatus(`Strong (${score}%)`, "success")
    } else {
      const msg = label === "service_unavailable" ? "Service unavailable" : `Weak (${score}%)`
      this._setStatus(msg, "danger")
    }
  }

  renderError() {
    this._setStatus("Could not check", "warning")
    this._setMeter(0)
  }

  _setStatus(text, type) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
      this.statusTarget.className = `badge text-bg-${type}`
    }
  }

  _setMeter(pct) {
    if (this.hasMeterTarget) {
      const clamped = Math.max(0, Math.min(100, pct || 0))
      this.meterTarget.style.width = `${clamped}%`
      this.meterTarget.setAttribute("aria-valuenow", clamped)
    }
  }
}

