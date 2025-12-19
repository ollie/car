class ServiceEntryForm {
  #priceInput
  #expenseInput

  constructor() {
    this.#priceInput = $("#service-entry-price")
    this.#expenseInput = $("#service-entry-expense")

    if (!this.#priceInput.length) {
      return
    }

    this.#priceInput.on("input", this.#handleInput.bind(this))
  }

  #handleInput = () => {
    this.#expenseInput.val(this.#priceInput.val())
  }
}

window.ServiceEntryForm = ServiceEntryForm
