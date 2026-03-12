class FuelEntryForm {
  #odometerInput
  #previousOdometer
  #tripWrapper
  #tripSpan
  #litersInput
  #totalPriceInput
  #unitPriceWrapper
  #unitPriceSpan

  constructor() {
    this.#odometerInput = $("#fuel-entry-odometer")

    if (!this.#odometerInput.length) {
      return
    }

    const $previousOdometer = $("#previous-fuel-entry-odometer")

    if ($previousOdometer.length) {
      this.#previousOdometer = $previousOdometer.data("value")
      this.#tripWrapper = $("#fuel-entry-trip")
      this.#tripSpan = this.#tripWrapper.find("span")

      this.#odometerInput.on("input", this.#handleOdometerInput.bind(this))
    }

    this.#litersInput = $("#fuel-entry-liters")
    this.#totalPriceInput = $("#fuel-entry-total_price")
    this.#unitPriceWrapper = $("#fuel-entry-unit-price")
    this.#unitPriceSpan = this.#unitPriceWrapper.find("span")

    this.#litersInput.add(this.#totalPriceInput).on("input", this.#handleUnitPrice.bind(this))
  }

  #handleOdometerInput() {
    const odometer = this.#odometerInput.val()
    const trip = odometer - this.#previousOdometer

    if (trip < 0) {
      this.#tripWrapper.addClass("d-none")
    } else {
      this.#tripSpan.text(trip)
      this.#tripWrapper.removeClass("d-none")
    }
  }

  #handleUnitPrice() {
    let liters = this.#litersInput.val()
    let totalPrice = this.#totalPriceInput.val()

    if (!liters || !totalPrice) {
      return
    }

    liters = Number(liters)
    totalPrice = Number(totalPrice)

    if (liters === 0) {
      return
    }

    let unitPrice = totalPrice / liters

    const parts = unitPrice.toFixed(2).split(".")
    parts[0] = parts[0].replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1 ")
    unitPrice = parts.join(",")

    this.#unitPriceSpan.text(unitPrice)
    this.#unitPriceWrapper.removeClass("d-none")
  }
}

window.FuelEntryForm = FuelEntryForm
