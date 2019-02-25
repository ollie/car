# TODO: Test all error messages nad translate them.
class FuelEntry < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter

  ###############
  # Class methods
  ###############

  class << self
    def new_with_defaults
      new(paid_on: Date.today)
    end

    def stats
      return unless count > 1

      @stats ||= OpenStruct.new.tap do |o|
        row = db[:fuel_entries]
              .where(Sequel.~(trip: nil))
              .select(Sequel.lit('count(*)').as(:entries))
              .select_append { sum(:liters).as(:liters) }
              .select_append { sum(:trip).as(:trips) }
              .select_append { sum(:total_price).as(:total_price) }
              .first

        o.entries      = row.fetch(:entries)
        o.trips        = row.fetch(:trips)
        o.liters       = row.fetch(:liters)
        o.total_price  = row.fetch(:total_price)
        o.unit_price   = o.total_price / o.liters
        o.price_per_km = o.total_price / o.trips
        o.consumption  = 100.0 / o.trips * o.liters
      end
    end

    def chart_data
      order(:paid_on, :id).map do |fuel_entry|
        [fuel_entry.paid_on, fuel_entry.odometer]
      end
    end

    def next_oil_change_date
      last_oil_change = ServiceEntry.ordered.first(engine_oil_change: true)

      return unless last_oil_change

      last_refuelling = ordered.first(full: true)

      return unless last_oil_change && last_refuelling

      days_since_last_oil_change     = (last_refuelling.paid_on - last_oil_change.date).to_i
      distance_since_last_oil_change = last_refuelling.odometer - last_oil_change.odometer

      return if distance_since_last_oil_change.zero?

      days_until_next_oil_change     = (10_000.0 / distance_since_last_oil_change * days_since_last_oil_change).to_i
      next_oil_change_date           = last_oil_change.date + days_until_next_oil_change
      year_later_oil_change_date     = last_oil_change.date.next_year
      effective_change_date =
        if next_oil_change_date > year_later_oil_change_date
          year_later_oil_change_date
        else
          next_oil_change_date
        end

      {
        predicted: next_oil_change_date,
        yearly:    year_later_oil_change_date,
        effective: effective_change_date
      }
    end
  end

  #################
  # Dataset methods
  #################

  dataset_module do
    def ordered
      order(Sequel.desc(:paid_on), Sequel.desc(:id))
    end
  end

  #############
  # Validations
  #############

  def validate
    super

    validates_presence [
      :paid_on,
      :odometer,
      :liters,
      :total_price
    ]
  end

  ###########
  # Callbacks
  ###########

  def before_save
    calculate_unit_price

    if previous_fuel_entry
      calculate_trip
      calculate_price_per_km_and_consumption
    end

    super
  end

  #########################
  # Public instance methods
  #########################

  def previous
    model.ordered.where(Sequel.lit('id < ?', id)).first
  end

  private

  ##########################
  # Private instance methods
  ##########################

  def previous_fuel_entry
    @previous_fuel_entry ||=
      if new?
        model.ordered.first
      else
        model.ordered.where(Sequel.lit('id < ?', id)).first
      end
  end

  def calculate_unit_price
    self.unit_price = total_price / liters
  end

  def calculate_trip
    self.trip = odometer - previous_fuel_entry.odometer
  end

  def calculate_price_per_km_and_consumption
    return unless full

    prices_total = total_price
    trips_total  = trip
    liters_total = liters

    model.ordered.where(Sequel.lit('trip IS NOT NULL AND id <= ?', previous_fuel_entry.id)).each do |fuel_entry|
      break if fuel_entry.full

      prices_total += fuel_entry.total_price
      trips_total  += fuel_entry.trip
      liters_total += fuel_entry.liters
    end

    self.price_per_km = prices_total / trips_total
    self.consumption  = 100.0 / trips_total * liters_total
  end
end
