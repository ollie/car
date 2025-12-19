class MileageChart {
  #element

  constructor() {
    this.#element = $("#mileage-chart")

    if (!this.#element.length) {
      return
    }

    HighchartsConfig.init()
    this.init()
  }

  init() {
    let data = JSON.parse($("#mileage-data").html())
    const plotLines = []
    let yearTmp = null

    data = data.map(item => {
      const date = new Date(item[0])
      const year = date.getFullYear()
      yearTmp = yearTmp != null ? yearTmp : year
      const timestamp = date.getTime()
      const value = item[1]

      if (year !== yearTmp) {
        const plotLineTimestamp = Date.UTC(year, 0, 1)
        plotLines.push(this.#createPlotLine(plotLineTimestamp, year))
        yearTmp = year
      }

      return [timestamp, value]
    })

    Highcharts.stockChart("mileage-chart", {
      chart: {
        spacing: [5, 0, 5, 0]
      },
      type: "line",
      title: {
        text: "Kilometry"
      },
      xAxis: {
        type: "datetime",
        ordinal: false,
        plotLines: plotLines
      },
      yAxis: {
        title: {
          text: "Km"
        }
      },
      series: [
        {
          name: "Odometer",
          showInNavigator: true,
          color: "#7cb5ec",
          lineWidth: 4,
          type: "line",
          index: 4,
          marker: {
            lineWidth: 4,
            radius: 6,
            lineColor: "#7cb5ec",
            fillColor: "white"
          },
          data: data
        }
      ],
      rangeSelector: {
        buttons: [
          {
            type: "year",
            count: 1,
            text: "Rok"
          },
          {
            type: "all",
            text: "Vše"
          }
        ],
        selected: 0,
        inputBoxWidth: 100,
        inputDateFormat: "%B %Y",
        inputEditDateFormat: "%d. %m. %Y"
      },
      credits: {
        enabled: false
      }
    })
  }

  #createPlotLine(value, text) {
    return {
      color: "#e6e6e6",
      value: value,
      width: 1,
      label: {
        text: text,
        style: {
          color: "#cccccc"
        }
      }
    }
  }
}

window.MileageChart = MileageChart
