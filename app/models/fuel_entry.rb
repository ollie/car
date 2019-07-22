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

  #########################
  # Public instance methods
  #########################

  def previous
    return @previous if defined?(@previous)

    @previous = model.ordered.where(Sequel.lit('id < ?', id)).first
  end

  def days_since_previous_entry
    return unless previous

    @days_since_previous_entry ||= (paid_on - previous.paid_on).to_i
  end

  def unit_price
    @unit_price ||=
      if total_price && liters
        total_price / liters
      else
        0
      end
  end

  def trip
    return @trip if defined?(@trip)

    @trip = nil
    @trip = odometer - previous_fuel_entry.odometer if previous_fuel_entry && odometer
  end

  def price_per_km
    return @price_per_km if defined?(@price_per_km)

    @price_per_km = nil

    return if partial || previous_fuel_entry.nil?

    prices_total = total_price
    trips_total  = trip

    previous_partial_fuel_entries.each do |fuel_entry|
      prices_total += fuel_entry.total_price
      trips_total  += fuel_entry.trip
    end

    @price_per_km = prices_total / trips_total
  end

  def consumption
    return @consumption if defined?(@consumption)

    @consumption = nil

    return if partial || previous_fuel_entry.nil?

    trips_total  = trip
    liters_total = liters

    previous_partial_fuel_entries.each do |fuel_entry|
      trips_total  += fuel_entry.trip
      liters_total += fuel_entry.liters
    end

    @consumption = 100.0 / trips_total * liters_total
  end

  def partial
    !full
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

  def previous_partial_fuel_entries
    @previous_partial_fuel_entries ||= [].tap do |fuel_entries|
      if previous_fuel_entry
        model.ordered.where(Sequel.lit('id <= ?', previous_fuel_entry.id)).each do |fuel_entry|
          break if fuel_entry.full

          fuel_entries << fuel_entry
        end
      end
    end
  end
end
