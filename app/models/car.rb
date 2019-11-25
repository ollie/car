# TODO: Test all error messages nad translate them.
class Car < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages

  ##############
  # Associations
  ##############

  one_to_many :fuel_entries do |ds|
    ds.order(Sequel.desc(:paid_on), Sequel.desc(:id))
  end

  one_to_many :service_entries do |ds|
    ds.order(Sequel.desc(:date), Sequel.desc(:id))
  end

  #################
  # Dataset methods
  #################

  dataset_module do
    def ordered
      order(:name)
    end
  end

  #############
  # Validations
  #############

  def validate
    super

    validates_presence %i[
      name
      engine_oil_change_distance_interval
      engine_oil_change_time_interval
      transmission_oil_change_distance_interval
      transmission_oil_change_time_interval
    ]

    validates_integer %i[
      engine_oil_change_distance_interval
      engine_oil_change_time_interval
      transmission_oil_change_distance_interval
      transmission_oil_change_time_interval
    ]
  end
end
