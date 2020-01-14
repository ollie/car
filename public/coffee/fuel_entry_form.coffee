class @FuelEntryForm
  constructor: ->
    @odometerInput = $('#fuel-entry-odometer')

    return unless @odometerInput.length

    $previousOdometer = $('#previous-fuel-entry-odometer')

    if $previousOdometer.length
      @previousOdometer = $previousOdometer.data('value')
      @tripWrapper      = $('#fuel-entry-trip')
      @tripSpan         = @tripWrapper.find('span')

      @odometerInput.on('input', @_handleOdometerInput)

    @litersInput      = $('#fuel-entry-liters')
    @totalPriceInput  = $('#fuel-entry-total_price')
    @unitPriceWrapper = $('#fuel-entry-unit-price')
    @unitPriceSpan    = @unitPriceWrapper.find('span')

    @litersInput.add(@totalPriceInput).on('input', @_handleUnitPrice)

  _handleOdometerInput: =>
    odometer = @odometerInput.val()
    trip     = odometer - @previousOdometer

    if trip < 0
      @tripWrapper.addClass('d-none')
    else
      @tripSpan.text(trip)
      @tripWrapper.removeClass('d-none')

  _handleUnitPrice: =>
    liters     = @litersInput.val()
    totalPrice = @totalPriceInput.val()

    return unless liters && totalPrice

    liters     = Number(liters)
    totalPrice = Number(totalPrice)

    return if liters == 0

    unitPrice = totalPrice / liters

    parts     = unitPrice.toFixed(2).split('.')
    parts[0]  = parts[0].replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1 ')
    unitPrice = parts.join(',')

    @unitPriceSpan.text(unitPrice)
    @unitPriceWrapper.removeClass('d-none')
