Sequel.migration do
  change do
    alter_table :service_entries do
      add_column :engine_oil_change, FalseClass, default: false, null: false
      add_column :transmission_oil_change, FalseClass, default: false, null: false

      add_index :engine_oil_change
      add_index :transmission_oil_change
    end
  end
end
