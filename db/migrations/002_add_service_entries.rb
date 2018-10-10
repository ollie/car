Sequel.migration do
  change do
    create_table :service_entries do
      primary_key :id

      String :title, size: 255, null: false
      Date :date, null: false
      Integer :odometer
      BigDecimal :price, size: [9, 2], null: false
      BigDecimal :expense, size: [9, 2], null: false
      String :note

      index :date
    end
  end
end
