Sequel.migration do
  up do
    alter_table :fuel_entries do
      add_foreign_key :car_id, :cars
    end

    car = self[:cars].order(:id).first
    self[:fuel_entries].update(car_id: car.fetch(:id)) if car

    alter_table :fuel_entries do
      set_column_not_null :car_id
    end
  end

  down do
    alter_table :fuel_entries do
      drop_foreign_key :car_id
    end
  end
end
