class FuelEntryForm
  constructor: ->
    @odometerInput = $('#fuel-entry-odometer')

    return unless @odometerInput.length

    $previousOdometer = $('#previous-fuel-entry-odometer')

    return unless $previousOdometer.length

    @previousOdometer = $previousOdometer.data('value')
    @tripWrapper      = $('#fuel-entry-trip')
    @tripSpan         = @tripWrapper.find('span')

    @odometerInput.on('input', this._handleInput)

  _handleInput: =>
    odometer = @odometerInput.val()
    trip     = odometer - @previousOdometer

    if trip < 0
      @tripWrapper.addClass('d-none')
    else
      @tripSpan.text(trip)
      @tripWrapper.removeClass('d-none')



class Confirm
  constructor: ->
    $items = $('[data-confirm]')
    $items.on('click', this._handleClick)

  _handleClick: (e) =>
    $item   = $(e.currentTarget)
    message = $item.data('confirm')

    if message && !confirm(message)
      e.preventDefault()



$ ->
  new FuelEntryForm
  new Confirm
