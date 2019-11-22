class @MileageChart
  constructor: ->
    @element = $('#mileage-chart')

    return unless @element.length

    HighchartsConfig.init()
    @init()

  init: ->
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
