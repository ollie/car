class Confirm
  constructor: ->
    $items = $('[data-confirm]')
    $items.on('click', this._handleClick)

  _handleClick: (e) =>
    $item   = $(e.currentTarget)
    message = $item.data('confirm')

    if message && !confirm(message)
      e.preventDefault()



class Toggle
  constructor: ->
    $items = $('[data-toggle-target]')

    $items.on('click', this._handleClick)

  _handleClick: (e) =>
    e.preventDefault()

    $source = $(e.currentTarget)
    $target = $($source.data('toggle-target'))

    $target.toggleClass('d-none')



class FuelEntryForm
  constructor: ->
    @odometerInput = $('#fuel-entry-odometer')

    return unless @odometerInput.length

    $previousOdometer = $('#previous-fuel-entry-odometer')

    return unless $previousOdometer.length

    @previousOdometer = $previousOdometer.data('value')
    @tripWrapper      = $('#fuel-entry-trip')
    @tripSpan         = @tripWrapper.find('span')

    @litersInput      = $('#fuel-entry-liters')
    @totalPriceInput  = $('#fuel-entry-total_price')
    @unitPriceWrapper = $('#fuel-entry-unit-price')
    @unitPriceSpan    = @unitPriceWrapper.find('span')

    @odometerInput.on('input', this._handleOdometerInput)
    @litersInput.add(@totalPriceInput).on('input', this._handleUnitPrice)

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



class ServiceEntryForm
  constructor: ->
    @priceInput   = $('#service-entry-price')
    @expenseInput = $('#service-entry-expense')

    return unless @priceInput.length

    @priceInput.on('input', this._handleInput)

  _handleInput: =>
    @expenseInput.val(@priceInput.val())



class HighchartsConfig
  constructor: ->
    Highcharts.setOptions
      credits:
        enabled: false
      lang:
        contextButtonTitle: 'Kontextové menu'
        decimalPoint: ','
        downloadCSV: 'Stáhnout CSV'
        downloadJPEG: 'Stáhnout JPEG'
        downloadPDF: 'Stáhnout PDF'
        downloadPNG: 'Stáhnout PNG'
        downloadSVG: 'Stáhnout SVG'
        downloadXLS: 'Stáhnout XLS'
        invalidDate: undefined
        loading: 'Načítám…'
        months: ['Leden' , 'Únor' , 'Březen' , 'Duben' , 'Květen' , 'Červen' , 'Červenec' , 'Srpen' , 'Září' , 'Říjen' , 'Listopad' , 'Prosinec']
        noData: 'Žádná data k zobrazení'
        numericSymbolMagnitude: 1000
        numericSymbols: ['k' , 'M' , 'G' , 'T' , 'P' , 'E']
        openInCloud: 'Otevřít v Highcharts Cloud'
        printChart: 'Tisknout'
        rangeSelectorFrom: 'Od'
        rangeSelectorTo: 'Do'
        rangeSelectorZoom: 'Zoom'
        resetZoom: 'Vyresetovat zoom'
        resetZoomTitle: 'Vyresetovat zoom na 1:1'
        shortMonths: ['Led' , 'Úno' , 'Bře' , 'Dub' , 'Kvě' , 'Čvn' , 'Čvc' , 'Spr' , 'Zář' , 'Říj' , 'Lis' , 'Pro']
        shortWeekdays: undefined
        thousandsSep: ' '
        weekdays: ['Neděle', 'Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota']



class MileageGraph
  constructor: ->
    $chart = $('#mileage-chart')

    return unless $chart.length

    this._loadChart()

  _loadChart: ->
    data = JSON.parse($('#mileage-data').html())

    data = data.map (item) ->
      date  = Date.parse(item[0])
      value = item[1]

      [date, value]

    Highcharts.chart 'mileage-chart', {
      title:
        text: 'Kilometry'
      xAxis:
        type: 'datetime'
      yAxis:
        title:
          text: 'Km'
      legend:
        enabled: false
      series: [
        {
          type: 'line'
          name: 'Odometer'
          data: data
        }
      ]
    }



$ ->
  new Confirm
  new Toggle
  new FuelEntryForm
  new ServiceEntryForm
  new HighchartsConfig
  new MileageGraph
