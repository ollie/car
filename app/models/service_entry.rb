# TODO: Test all error messages nad translate them.
class ServiceEntry < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter

  ###############
  # Class methods
  ###############

  class << self
    def new_with_defaults
      new(date: Date.today)
    end
  end

  #################
  # Dataset methods
  #################

  dataset_module do
    def ordered
      order(Sequel.desc(:date), Sequel.desc(:id))
    end
  end

  #############
  # Validations
  #############

  def validate
    super

    validates_presence %i[
      title
      date
      price
      expense
    ]
  end
end
