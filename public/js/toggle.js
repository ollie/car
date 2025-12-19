class Toggle {
  constructor() {
    const $items = $("[data-toggle-target]")

    $items.on("click", this.#handleClick.bind(this))
  }

  #handleClick(e) {
    e.preventDefault()

    const $source = $(e.currentTarget)
    const $target = $($source.data("toggle-target"))

    $target.toggleClass("d-none")
  }
}

window.Toggle = Toggle
