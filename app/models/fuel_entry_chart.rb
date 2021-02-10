class FuelEntryChart
  attr_accessor :car

  def initialize(car)
    self.car = car
  end

  def chart_data
    car.fuel_entries_dataset.order(:paid_on, :id).map do |fuel_entry|
      [fuel_entry.paid_on, fuel_entry.odometer]
    end
  end

  def next_engine_oil_change_date
    @next_engine_oil_change_date ||= next_change_date(
      last_change:       car.service_entries_dataset.first(engine_oil_change: true),
      distance_interval: car.engine_oil_change_distance_interval,
      years_interval:    car.engine_oil_change_time_interval
    )
  end

  def next_transmission_oil_change_date
    @next_transmission_oil_change_date ||= next_change_date(
      last_change:       car.service_entries_dataset.first(transmission_oil_change: true),
      distance_interval: car.transmission_oil_change_distance_interval,
      years_interval:    car.transmission_oil_change_time_interval
    )
  end

  private

  def next_change_date(last_change:, distance_interval:, years_interval:)
    return unless last_change

    last_refuelling = car.fuel_entries_dataset.first(full: true)

    return unless last_change && last_refuelling

    days_since_last_change     = (last_refuelling.paid_on - last_change.date).to_i
    distance_since_last_change = last_refuelling.odometer - last_change.odometer

    return if days_since_last_change < 0 || distance_since_last_change <= 0

    days_to_next_change   = (distance_interval.to_f / distance_since_last_change * days_since_last_change).to_i
    next_change_date      = last_change.date + days_to_next_change
    scheduled_change_date = last_change.date.next_year(years_interval)
    effective_change_date = [next_change_date, scheduled_change_date].min

    distance_per_year = ((years_interval * 365) / (last_refuelling.paid_on - last_change.date).to_f * distance_since_last_change).to_i

    {
      predicted: next_change_date,
      scheduled: scheduled_change_date,
      effective: effective_change_date,
      distance_per_year: distance_per_year
    }
  end
end
