Sequel.migration do
  up do
    create_table :cars do
      primary_key :id

      String :name, size: 255
      Integer :engine_oil_change_distance_interval
      Integer :engine_oil_change_time_interval
      Integer :transmission_oil_change_distance_interval
      Integer :transmission_oil_change_time_interval

      index :name
    end

    if self[:fuel_entries].any? || self[:service_entries].any?
      self[:cars].insert(
        name: 'Subaru Legacy',
        engine_oil_change_distance_interval: 10_000,
        engine_oil_change_time_interval: 1,
        transmission_oil_change_distance_interval: 60_000,
        transmission_oil_change_time_interval: 4
      )
    end

    alter_table :cars do
      set_column_not_null :name
      set_column_not_null :engine_oil_change_distance_interval
      set_column_not_null :engine_oil_change_time_interval
      set_column_not_null :transmission_oil_change_distance_interval
      set_column_not_null :transmission_oil_change_time_interval
    end
  end

  down do
    drop_table :cars
  end
end
