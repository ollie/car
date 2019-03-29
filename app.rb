class App < Sinatra::Base
  configure do
    Settings.database
    Settings.setup_i18n
    Settings.load_files('lib/**')
    Settings.load_files('models/**')
  end

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

      redirect fuel_entries_path
    else
      slim :'sessions/new', layout: :'layouts/sessions', locals: {
        login_failed: true
      }
    end
  end

  ##############
  # Fuel Entries
  ##############

  get '/' do
    redirect fuel_entries_path
  end

  get Route(fuel_entries: '/fuel_entries') do
    if FuelEntry.count.zero?
      redirect new_fuel_entry_path
    else
      slim :'fuel_entries/index'
    end
  end

  get Route(new_fuel_entry: '/fuel_entries/new') do
    slim :'fuel_entries/new', locals: {
      fuel_entry: FuelEntry.new_with_defaults,
      previous_fuel_entry: FuelEntry.ordered.first
    }
  end

  post '/fuel_entries/new' do
    fuel_entry = FuelEntry.new
    fuel_entry.set_fields(params[:fuel_entry], [:full, :paid_on, :odometer, :liters, :total_price, :note])

    if fuel_entry.valid?
      fuel_entry.save
      redirect fuel_entries_path
    else
      slim :'fuel_entries/new', locals: {
        fuel_entry: fuel_entry,
        previous_fuel_entry: FuelEntry.ordered.first
      }
    end
  end

  get Route(edit_fuel_entry: '/fuel_entries/:id/edit') do
    fuel_entry = FuelEntry.with_pk!(params[:id])

    slim :'fuel_entries/edit', locals: {
      fuel_entry: fuel_entry,
      previous_fuel_entry: fuel_entry.previous
    }
  end

  post '/fuel_entries/:id/edit' do
    fuel_entry = FuelEntry.with_pk!(params[:id])
    fuel_entry.set_fields(params[:fuel_entry], [:full, :paid_on, :odometer, :liters, :total_price, :note])

    if fuel_entry.valid?
      fuel_entry.save
      redirect fuel_entries_path
    else
      slim :'fuel_entries/new', locals: {
        fuel_entry: fuel_entry,
        previous_fuel_entry: fuel_entry.previous
      }
    end
  end

  post Route(delete_fuel_entry: '/fuel_entries/:id/delete') do
    fuel_entry = FuelEntry.with_pk!(params[:id])
    fuel_entry.destroy
    redirect fuel_entries_path
  end

  #################
  # Service Entries
  #################

  get Route(service_entries: '/service_entries') do
    if ServiceEntry.count.zero?
      redirect new_service_entry_path
    else
      slim :'service_entries/index'
    end
  end

  get Route(new_service_entry: '/service_entries/new') do
    slim :'service_entries/new', locals: {
      service_entry: ServiceEntry.new_with_defaults
    }
  end

  post '/service_entries/new' do
    service_entry = ServiceEntry.new
    service_entry.set_fields(params[:service_entry], [:title, :date, :odometer, :price, :expense, :note, :engine_oil_change, :transmission_oil_change])

    if service_entry.valid?
      service_entry.save
      redirect service_entries_path
    else
      slim :'service_entries/new', locals: {
        service_entry: service_entry
      }
    end
  end

  get Route(edit_service_entry: '/service_entries/:id/edit') do
    slim :'service_entries/edit', locals: {
      service_entry: ServiceEntry.with_pk!(params[:id])
    }
  end

  post '/service_entries/:id/edit' do
    service_entry = ServiceEntry.with_pk!(params[:id])
    service_entry.set_fields(params[:service_entry], [:title, :date, :odometer, :price, :expense, :note, :engine_oil_change, :transmission_oil_change])

    if service_entry.valid?
      service_entry.save
      redirect service_entries_path
    else
      slim :'service_entries/new', locals: {
        service_entry: service_entry,
        previous_service_entry: service_entry.previous
      }
    end
  end

  post Route(delete_service_entry: '/service_entries/:id/delete') do
    service_entry = ServiceEntry.with_pk!(params[:id])
    service_entry.destroy
    redirect service_entries_path
  end
end
