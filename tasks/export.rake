desc 'Export data s JSON and .dump'
task export: ['export:json_export', 'export:db_export']

namespace :export do
  desc 'Export data as JSON'
  task json_export: :environment do
    data = {}

    data['fuel_entries'] = FuelEntry.order(:id).map do |fuel_entry|
      {
        # id:           fuel_entry.id,
        paid_on:      fuel_entry.paid_on,
        full:         fuel_entry.full,
        odometer:     fuel_entry.odometer,
        trip:         fuel_entry.trip,
        liters:       fuel_entry.liters,
        total_price:  fuel_entry.total_price,
        unit_price:   fuel_entry.unit_price,
        price_per_km: fuel_entry.price_per_km,
        consumption:  fuel_entry.consumption,
        note:         fuel_entry.note
      }
    end

    data['service_entries'] = ServiceEntry.order(:id).map do |service_entry|
      {
        # id:       service_entry.id,
        title:    service_entry.title,
        date:     service_entry.date,
        odometer: service_entry.odometer,
        price:    service_entry.price,
        expense:  service_entry.expense,
        note:     service_entry.note
      }
    end

    mkdir_p 'data'
    file = 'data/data.json'

    if File.file?(file)
      mv file, "data/data-#{Time.now.strftime('%Y%m%d-%H%M%S')}.json"
    end

    File.write(file, JSON.pretty_generate(data))
    puts file
  end

  desc 'Import data as JSON'
  task json_import: :environment do
    file = 'data/data.json'
    abort 'There is nothing to import.' unless File.file?(file)

    data = JSON.load(File.read(file))

    Settings.database[:fuel_entries].truncate(cascade: true, restart: true)
    Settings.database[:service_entries].truncate(cascade: true, restart: true)

    data['fuel_entries'].each do |item|
      FuelEntry.create(item)
    end

    data['service_entries'].each do |item|
      ServiceEntry.create(item)
    end
  end

  desc 'Export database as .dump'
  task db_export: :environment do
    db        = Settings.database_url.split('/').last
    dump_path = "data/data-#{Time.now.strftime('%Y%m%d-%H%M%S')}.dump"

    sh "pg_dump -Fc -c #{db} > #{dump_path}"
  end

  desc 'Import .dump database'
  task db_import: :environment do
    db        = Settings.database_url.split('/').last
    dump_path = Dir['data/data-*.dump'].sort.last

    abort 'No dump found' unless dump_path

    sh "pg_restore -c -d #{db} #{dump_path}"
  end
end
