class @ServiceEntryForm
  constructor: ->
    @priceInput   = $('#service-entry-price')
    @expenseInput = $('#service-entry-expense')

    return unless @priceInput.length

    @priceInput.on('input', @_handleInput)

  _handleInput: =>
    @expenseInput.val(@priceInput.val())
