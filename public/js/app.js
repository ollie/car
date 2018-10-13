// Generated by CoffeeScript 1.10.0
(function() {
  var Confirm, FuelEntryForm, HighchartsConfig, MileageGraph, ServiceEntryForm, Toggle,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Confirm = (function() {
    function Confirm() {
      this._handleClick = bind(this._handleClick, this);
      var $items;
      $items = $('[data-confirm]');
      $items.on('click', this._handleClick);
    }

    Confirm.prototype._handleClick = function(e) {
      var $item, message;
      $item = $(e.currentTarget);
      message = $item.data('confirm');
      if (message && !confirm(message)) {
        return e.preventDefault();
      }
    };

    return Confirm;

  })();

  Toggle = (function() {
    function Toggle() {
      this._handleClick = bind(this._handleClick, this);
      var $items;
      $items = $('[data-toggle-target]');
      $items.on('click', this._handleClick);
    }

    Toggle.prototype._handleClick = function(e) {
      var $source, $target;
      e.preventDefault();
      $source = $(e.currentTarget);
      $target = $($source.data('toggle-target'));
      return $target.toggleClass('d-none');
    };

    return Toggle;

  })();

  FuelEntryForm = (function() {
    function FuelEntryForm() {
      this._handleUnitPrice = bind(this._handleUnitPrice, this);
      this._handleOdometerInput = bind(this._handleOdometerInput, this);
      var $previousOdometer;
      this.odometerInput = $('#fuel-entry-odometer');
      if (!this.odometerInput.length) {
        return;
      }
      $previousOdometer = $('#previous-fuel-entry-odometer');
      if (!$previousOdometer.length) {
        return;
      }
      this.previousOdometer = $previousOdometer.data('value');
      this.tripWrapper = $('#fuel-entry-trip');
      this.tripSpan = this.tripWrapper.find('span');
      this.litersInput = $('#fuel-entry-liters');
      this.totalPriceInput = $('#fuel-entry-total_price');
      this.unitPriceWrapper = $('#fuel-entry-unit-price');
      this.unitPriceSpan = this.unitPriceWrapper.find('span');
      this.odometerInput.on('input', this._handleOdometerInput);
      this.litersInput.add(this.totalPriceInput).on('input', this._handleUnitPrice);
    }

    FuelEntryForm.prototype._handleOdometerInput = function() {
      var odometer, trip;
      odometer = this.odometerInput.val();
      trip = odometer - this.previousOdometer;
      if (trip < 0) {
        return this.tripWrapper.addClass('d-none');
      } else {
        this.tripSpan.text(trip);
        return this.tripWrapper.removeClass('d-none');
      }
    };

    FuelEntryForm.prototype._handleUnitPrice = function() {
      var liters, parts, totalPrice, unitPrice;
      liters = this.litersInput.val();
      totalPrice = this.totalPriceInput.val();
      if (!(liters && totalPrice)) {
        return;
      }
      liters = Number(liters);
      totalPrice = Number(totalPrice);
      if (liters === 0) {
        return;
      }
      unitPrice = totalPrice / liters;
      parts = unitPrice.toFixed(2).split('.');
      parts[0] = parts[0].replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1 ');
      unitPrice = parts.join(',');
      this.unitPriceSpan.text(unitPrice);
      return this.unitPriceWrapper.removeClass('d-none');
    };

    return FuelEntryForm;

  })();

  ServiceEntryForm = (function() {
    function ServiceEntryForm() {
      this._handleInput = bind(this._handleInput, this);
      this.priceInput = $('#service-entry-price');
      this.expenseInput = $('#service-entry-expense');
      if (!this.priceInput.length) {
        return;
      }
      this.priceInput.on('input', this._handleInput);
    }

    ServiceEntryForm.prototype._handleInput = function() {
      return this.expenseInput.val(this.priceInput.val());
    };

    return ServiceEntryForm;

  })();

  HighchartsConfig = (function() {
    function HighchartsConfig() {
      Highcharts.setOptions({
        credits: {
          enabled: false
        },
        lang: {
          contextButtonTitle: 'Kontextové menu',
          decimalPoint: ',',
          downloadCSV: 'Stáhnout CSV',
          downloadJPEG: 'Stáhnout JPEG',
          downloadPDF: 'Stáhnout PDF',
          downloadPNG: 'Stáhnout PNG',
          downloadSVG: 'Stáhnout SVG',
          downloadXLS: 'Stáhnout XLS',
          invalidDate: void 0,
          loading: 'Načítám…',
          months: ['Leden', 'Únor', 'Březen', 'Duben', 'Květen', 'Červen', 'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosinec'],
          noData: 'Žádná data k zobrazení',
          numericSymbolMagnitude: 1000,
          numericSymbols: ['k', 'M', 'G', 'T', 'P', 'E'],
          openInCloud: 'Otevřít v Highcharts Cloud',
          printChart: 'Tisknout',
          rangeSelectorFrom: 'Od',
          rangeSelectorTo: 'Do',
          rangeSelectorZoom: 'Zoom',
          resetZoom: 'Vyresetovat zoom',
          resetZoomTitle: 'Vyresetovat zoom na 1:1',
          shortMonths: ['Led', 'Úno', 'Bře', 'Dub', 'Kvě', 'Čvn', 'Čvc', 'Spr', 'Zář', 'Říj', 'Lis', 'Pro'],
          shortWeekdays: void 0,
          thousandsSep: ' ',
          weekdays: ['Neděle', 'Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota']
        }
      });
    }

    return HighchartsConfig;

  })();

  MileageGraph = (function() {
    function MileageGraph() {
      var $chart;
      $chart = $('#mileage-chart');
      if (!$chart.length) {
        return;
      }
      this._loadChart();
    }

    MileageGraph.prototype._loadChart = function() {
      var data;
      data = JSON.parse($('#mileage-data').html());
      data = data.map(function(item) {
        var date, value;
        date = Date.parse(item[0]);
        value = item[1];
        return [date, value];
      });
      return Highcharts.chart('mileage-chart', {
        title: {
          text: 'Kilometry'
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          title: {
            text: 'Km'
          }
        },
        legend: {
          enabled: false
        },
        series: [
          {
            type: 'line',
            name: 'Odometer',
            data: data
          }
        ]
      });
    };

    return MileageGraph;

  })();

  $(function() {
    new Confirm;
    new Toggle;
    new FuelEntryForm;
    new ServiceEntryForm;
    new HighchartsConfig;
    return new MileageGraph;
  });

}).call(this);
