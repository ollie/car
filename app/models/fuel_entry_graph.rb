class FuelEntryGraph
  def chart_data
    FuelEntry.order(:paid_on, :id).map do |fuel_entry|
      [fuel_entry.paid_on, fuel_entry.odometer]
    end
  end

  def next_engine_oil_change_date
    @next_engine_oil_change_date ||= next_change_date(
      last_change: ServiceEntry.ordered.first(engine_oil_change: true),
      distance_interval: 10_000,
      years_interval: 1
    )
  end

  def next_transmission_oil_change_date
    @next_transmission_oil_change_date ||= next_change_date(
      last_change: ServiceEntry.ordered.first(transmission_oil_change: true),
      distance_interval: 60_000,
      years_interval: 4
    )
  end

  private

  def next_change_date(last_change:, distance_interval:, years_interval:)
    return unless last_change

    last_refuelling = FuelEntry.ordered.first(full: true)

    return unless last_change && last_refuelling

    days_since_last_change     = (last_refuelling.paid_on - last_change.date).to_i
    distance_since_last_change = last_refuelling.odometer - last_change.odometer

    return if days_since_last_change < 0 || distance_since_last_change <= 0

    days_to_next_change   = (distance_interval.to_f / distance_since_last_change * days_since_last_change).to_i
    next_change_date      = last_change.date + days_to_next_change
    scheduled_change_date = last_change.date.next_year(years_interval)
    effective_change_date = [next_change_date, scheduled_change_date].min

    {
      predicted: next_change_date,
      scheduled: scheduled_change_date,
      effective: effective_change_date
    }
  end
end
