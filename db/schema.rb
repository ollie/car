# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:fuel_entries) do
      primary_key :id
      column :paid_on, 'date', null: false
      column :full, 'boolean', default: true, null: false
      column :odometer, 'integer', null: false
      column :liters, 'numeric(5,2)', null: false
      column :total_price, 'numeric(7,2)', null: false
      column :note, 'character varying(255)'

      index [:paid_on]
    end

    create_table(:schema_info) do
      column :version, 'integer', default: 0, null: false
    end

    create_table(:service_entries) do
      primary_key :id
      column :title, 'character varying(255)', null: false
      column :date, 'date', null: false
      column :odometer, 'integer'
      column :price, 'numeric(9,2)', null: false
      column :expense, 'numeric(9,2)', null: false
      column :note, 'text'
      column :engine_oil_change, 'boolean', default: false, null: false
      column :transmission_oil_change, 'boolean', default: false, null: false

      index [:date]
      index [:engine_oil_change]
      index [:transmission_oil_change]
    end
  end
end
