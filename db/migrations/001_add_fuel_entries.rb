Sequel.migration do
  change do
    create_table :fuel_entries do
      primary_key :id

      Date :paid_on, null: false
      Boolean :full, default: true, null: false
      Integer :odometer, null: false
      Integer :trip
      BigDecimal :liters, size: [5, 2], null: false
      BigDecimal :total_price, size: [7, 2], null: false
      BigDecimal :unit_price, size: [5, 2], null: false
      BigDecimal :price_per_km, size: [4, 2]
      BigDecimal :consumption, size: [5, 2]
      String :note, size: 255

      index :paid_on
    end
  end
end
