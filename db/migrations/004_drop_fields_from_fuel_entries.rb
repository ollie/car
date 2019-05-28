Sequel.migration do
  change do
    alter_table :fuel_entries do
      drop_column :unit_price
      drop_column :trip
      drop_column :price_per_km
      drop_column :consumption
    end
  end
end
