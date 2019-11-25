class FuelEntryStats
  attr_accessor :car
  attr_accessor :entries
  attr_accessor :trips
  attr_accessor :liters
  attr_accessor :total_price
  attr_accessor :unit_price
  attr_accessor :price_per_km
  attr_accessor :consumption

  def initialize(car)
    self.car          = car
    self.entries      = 0
    self.trips        = 0
    self.liters       = 0
    self.total_price  = 0

    perform if calculate?
  end

  def calculate?
    car.fuel_entries_dataset.count > 1
  end

  private

  def perform
    car.fuel_entries_dataset.each do |fuel_entry|
      next unless fuel_entry.trip

      self.entries      += 1
      self.trips        += fuel_entry.trip
      self.liters       += fuel_entry.liters
      self.total_price  += fuel_entry.total_price
    end

    self.unit_price   = total_price / liters
    self.price_per_km = total_price / trips
    self.consumption  = 100.0 / trips * liters
  end
end
