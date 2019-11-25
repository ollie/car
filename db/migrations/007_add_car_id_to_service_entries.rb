Sequel.migration do
  up do
    alter_table :service_entries do
      add_foreign_key :car_id, :cars
    end

    car = self[:cars].order(:id).first
    self[:service_entries].update(car_id: car.fetch(:id)) if car

    alter_table :service_entries do
      set_column_not_null :car_id
    end
  end

  down do
    alter_table :service_entries do
      drop_foreign_key :car_id
    end
  end
end
