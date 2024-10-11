class App < Sinatra::Base
  configure do
    Settings.database
    Settings.setup_i18n
  end

  set :public_folder, Settings.root.join('public')
  set :slim, layout: :'layouts/application',
             pretty: true
  set :sessions, expire_after: 14.days
  set :session_secret, Settings.secrets.session_secret

  register Sinatra::Routing
  helpers Sinatra::CommonHelpers
  helpers Sinatra::AppHelpers

  #######
  # Hooks
  #######

  before do
    pass if request.path == new_session_path
    pass if Login.valid?(session[:encrypted_username], session[:encrypted_password])

    redirect new_session_path
  end

  ##########
  # Sessions
  ##########

  get Route(new_session: '/sessions/new') do
    slim :'sessions/new', layout: :'layouts/sessions'
  end

  post '/sessions/new' do
    encrypted_username = Login.encrypt_username(params[:username])
    encrypted_password = Login.encrypt_password(params[:password])

    if Login.valid?(encrypted_username, encrypted_password)
      session[:encrypted_username] = encrypted_username
      session[:encrypted_password] = encrypted_password

      cars = Car.ordered

      if cars.count.zero?
        redirect new_car_path
      elsif cars.count == 1
        redirect car_path(cars.first.id)
      else
        redirect cars_path
      end
    else
      slim :'sessions/new', layout: :'layouts/sessions', locals: {
        login_failed: true
      }
    end
  end

  ######
  # Cars
  ######

  get '/' do
    cars = Car.ordered

    if cars.count.zero?
      redirect new_car_path
    elsif cars.count == 1
      redirect car_path(cars.first.id)
    else
      redirect cars_path
    end
  end

  get Route(cars: '/cars') do
    cars = Car.ordered

    if cars.count.zero?
      redirect new_car_path
    else
      slim :'cars/index', locals: {
        cars: cars
      }
    end
  end

  get Route(new_car: '/cars/new') do
    slim :'cars/new', locals: {
      car: Car.new
    }
  end

  post '/cars/new' do
    car = Car.new
    car.set_fields(params[:car], %i[name engine_oil_change_distance_interval engine_oil_change_time_interval transmission_oil_change_distance_interval transmission_oil_change_time_interval])

    if car.valid?
      car.save
      redirect cars_path
    else
      slim :'cars/new', locals: {
        car: car
      }
    end
  end

  get Route(edit_car: '/cars/:id/edit') do
    slim :'cars/edit', locals: {
      car: Car.with_pk!(params[:id])
    }
  end

  post '/cars/:id/edit' do
    car = Car.with_pk!(params[:id])
    car.set_fields(params[:car], %i[name engine_oil_change_distance_interval engine_oil_change_time_interval transmission_oil_change_distance_interval transmission_oil_change_time_interval])

    if car.valid?
      car.save
      redirect car_path(car.id)
    else
      slim :'cars/edit', locals: {
        car: car
      }
    end
  end

  post Route(delete_car: '/cars/:id/delete') do
    car = Car.with_pk!(params[:id])
    car.destroy
    redirect cars_path
  end

  get Route(car: '/car/:id') do
    car             = Car.with_pk!(params[:id])
    fuel_entries    = car.fuel_entries_dataset.limit(5)
    service_entries = car.service_entries_dataset.limit(5)

    slim :'cars/show', locals: {
      car:              car,
      fuel_entries:     fuel_entries,
      service_entries:  service_entries,
      fuel_entry_chart: FuelEntryChart.new(car)
    }
  end

  ##############
  # Fuel Entries
  ##############

  get Route(fuel_entries: '/cars/:car_id/fuel_entries') do
    car          = Car.with_pk!(params[:car_id])
    fuel_entries = car.fuel_entries_dataset.paginate(params[:page], per_page: 15)

    if fuel_entries.count.zero?
      redirect new_fuel_entry_path(car.id)
    else
      slim :'fuel_entries/index', locals: {
        car:              car,
        fuel_entries:     fuel_entries,
        fuel_entry_stats: FuelEntryStats.new(car.fuel_entries_dataset)
      }
    end
  end

  get Route(new_fuel_entry: '/cars/:car_id/fuel_entries/new') do
    car = Car.with_pk!(params[:car_id])

    slim :'fuel_entries/new', locals: {
      car:                 car,
      fuel_entry:          FuelEntry.new_with_defaults(car),
      previous_fuel_entry: car.fuel_entries_dataset.first
    }
  end

  post '/cars/:car_id/fuel_entries/new' do
    car        = Car.with_pk!(params[:car_id])
    fuel_entry = FuelEntry.new(car_id: car.id)
    fuel_entry.set_fields(params[:fuel_entry], %i[full paid_on odometer liters total_price note])

    if fuel_entry.valid?
      fuel_entry.save
      redirect fuel_entries_path(car.id)
    else
      slim :'fuel_entries/new', locals: {
        car:                 car,
        fuel_entry:          fuel_entry,
        previous_fuel_entry: car.fuel_entries_dataset.first
      }
    end
  end

  get Route(edit_fuel_entry: '/cars/:car_id/fuel_entries/:id/edit') do
    car        = Car.with_pk!(params[:car_id])
    fuel_entry = car.fuel_entries_dataset.with_pk!(params[:id])

    slim :'fuel_entries/edit', locals: {
      car:                 car,
      fuel_entry:          fuel_entry,
      previous_fuel_entry: fuel_entry.previous
    }
  end

  post '/cars/:car_id/fuel_entries/:id/edit' do
    car        = Car.with_pk!(params[:car_id])
    fuel_entry = car.fuel_entries_dataset.with_pk!(params[:id])
    fuel_entry.set_fields(params[:fuel_entry], %i[full paid_on odometer liters total_price note])

    if fuel_entry.valid?
      fuel_entry.save
      redirect fuel_entries_path(car.id)
    else
      slim :'fuel_entries/edit', locals: {
        car:                 car,
        fuel_entry:          fuel_entry,
        previous_fuel_entry: fuel_entry.previous
      }
    end
  end

  post Route(delete_fuel_entry: '/cars/:car_id/fuel_entries/:id/delete') do
    car        = Car.with_pk!(params[:car_id])
    fuel_entry = car.fuel_entries_dataset.with_pk!(params[:id])
    fuel_entry.destroy
    redirect fuel_entries_path(car.id)
  end

  #################
  # Service Entries
  #################

  get Route(service_entries: '/cars/:car_id/service_entries') do
    car             = Car.with_pk!(params[:car_id])
    service_entries = car.service_entries_dataset.paginate(params[:page], per_page: 15)

    if service_entries.count.zero?
      redirect new_service_entry_path(car.id)
    else
      slim :'service_entries/index', locals: {
        car:                 car,
        service_entries:     service_entries,
        service_entry_stats: ServiceEntryStats.new(car.service_entries_dataset)
      }
    end
  end

  get Route(new_service_entry: '/cars/:car_id/service_entries/new') do
    car = Car.with_pk!(params[:car_id])

    slim :'service_entries/new', locals: {
      car:           car,
      service_entry: ServiceEntry.new_with_defaults(car)
    }
  end

  post '/cars/:car_id/service_entries/new' do
    car           = Car.with_pk!(params[:car_id])
    service_entry = ServiceEntry.new(car_id: car.id)
    service_entry.set_fields(params[:service_entry], %i[title date odometer price expense note engine_oil_change transmission_oil_change])

    if service_entry.valid?
      service_entry.save
      redirect service_entries_path(car.id)
    else
      slim :'service_entries/new', locals: {
        car:           car,
        service_entry: service_entry
      }
    end
  end

  get Route(edit_service_entry: '/cars/:car_id/service_entries/:id/edit') do
    car           = Car.with_pk!(params[:car_id])
    service_entry = car.service_entries_dataset.with_pk!(params[:id])

    slim :'service_entries/edit', locals: {
      car:           car,
      service_entry: service_entry
    }
  end

  post '/cars/:car_id/service_entries/:id/edit' do
    car           = Car.with_pk!(params[:car_id])
    service_entry = car.service_entries_dataset.with_pk!(params[:id])
    service_entry.set_fields(params[:service_entry], %i[title date odometer price expense note engine_oil_change transmission_oil_change])

    if service_entry.valid?
      service_entry.save
      redirect service_entries_path(car.id)
    else
      slim :'service_entries/edit', locals: {
        car:           car,
        service_entry: service_entry
      }
    end
  end

  post Route(delete_service_entry: '/cars/:car_id/service_entries/:id/delete') do
    car           = Car.with_pk!(params[:car_id])
    service_entry = car.service_entries_dataset.with_pk!(params[:id])
    service_entry.destroy
    redirect service_entries_path(car.id)
  end
end
