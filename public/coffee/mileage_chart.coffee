class @MileageChart
  constructor: ->
    @element = $('#mileage-chart')

    return unless @element.length

    HighchartsConfig.init()
    @init()

  init: ->
    data      = JSON.parse($('#mileage-data').html())
    plotLines = []
    yearTmp   = null

    data = data.map (item) =>
      date      = new Date(item[0])
      year      = date.getFullYear()
      yearTmp  ?= year
      timestamp = date.getTime()
      value     = item[1]

      if year != yearTmp
        plotLineTimestamp = Date.UTC(year, 0, 1)
        plotLines.push(@_createPlotLine(plotLineTimestamp, year))
        yearTmp = year

      [timestamp, value]

    Highcharts.stockChart 'mileage-chart', {
      chart:
        spacing: [5, 0, 5, 0]
      type: 'line'
      title:
        text: 'Kilometry'
      xAxis:
        type: 'datetime'
        ordinal: false # Keep dates to scale
        plotLines: plotLines
      yAxis:
        title:
          text: 'Km'
      series: [
        {
          name: 'Odometer'
          showInNavigator: true
          color: '#7cb5ec'
          lineWidth: 4
          type: 'line'
          index: 4
          marker:
            lineWidth: 4
            radius: 6
            lineColor: '#7cb5ec'
            fillColor: 'white'
          data: data
        }
      ]
      rangeSelector:
        buttons: [
          {
            type: 'year'
            count: 1
            text: 'Rok'
          },
          {
            type: 'all'
            text: 'Vše'
          }
        ]
        selected: 0
        inputBoxWidth: 100
        inputDateFormat: '%B %Y'
        inputEditDateFormat: '%d. %m. %Y'
      credits:
        enabled: false
    }

  _createPlotLine: (value, text) ->
    {
      color: '#e6e6e6'
      value: value
      width: 1
      label:
        text: text
        style:
          color: '#cccccc'
    }
