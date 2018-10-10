class App < Sinatra::Base
  set :slim, layout: :'layouts/application',
             pretty: true

  configure do
    config = YAML.safe_load(File.read("#{settings.root}/config/secrets.yml"))
    config = config.fetch(ENV['RACK_ENV'])

    set :login_encrypted_username, config.fetch('login_encrypted_username')
    set :login_encrypted_password, config.fetch('login_encrypted_password')

    Settings.database
    Settings.setup_i18n
    Settings.load_files('lib/**')
    Settings.load_files('models/**')
  end

  use Rack::Auth::Basic, 'Whee' do |username, password|
    encrypted_username = Digest::SHA256.hexdigest(username)
    encrypted_password = Digest::SHA256.hexdigest(password)

    encrypted_username == settings.login_encrypted_username &&
      encrypted_password == settings.login_encrypted_password
  end if Settings.production?

  def self.Route(hash)
    route_name = hash.keys.first
    route_path = hash[route_name]

    helpers do
      define_method("#{route_name}_path") do |id = nil|
        if route_path =~ /:id/
          raise ArgumentError, "Missing :id parameter for route #{route_path}" unless id
          route_path.gsub(':id', id.to_s)
        else
          route_path
        end
      end
    end

    route_path
  end

  helpers do
    def partial_slim(template, locals = {})
      slim(template.to_sym, layout: false, locals: locals)
    end

    def title(text = nil, head: false)
      return @title = text if text
      return [@title, t('title')].compact.join(' – ') if head

      @title
    end

    def icon(filename)
      @@icon_cache ||= {}
      @@icon_cache[filename] ||= begin
        svg = Settings.root.join('public/svg/octicons', "#{filename}.svg").read
        %(<span class="octicon">#{svg}</span>)
      end
    end

    def t(key, options = nil)
      I18n.t(key, options)
    end

    def l(key, options = nil)
      I18n.l(key, options)
    end

    def format_number(number, format: '%.02f')
      format(format, number).tap do |s|
        s.reverse!
        s.gsub!(/(\d{3})(\d)/, '\1 \2')
        s.tr!('.', ',')
        s.reverse!
      end
    end
  end

  get '/' do
    redirect fuel_entries_path
  end

  ##############
  # Fuel Entries
  ##############

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
    service_entry.set_fields(params[:service_entry], [:title, :date, :odometer, :price, :expense, :note])

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
    service_entry.set_fields(params[:service_entry], [:title, :date, :odometer, :price, :expense, :note])

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
