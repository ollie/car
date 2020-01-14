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

    Highcharts.chart 'mileage-chart', {
      title:
        text: 'Kilometry'
      xAxis:
        type: 'datetime'
        plotLines: plotLines
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
