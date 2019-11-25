# TODO: Test all error messages nad translate them.
class ServiceEntry < Sequel::Model
  #########
  # Plugins
  #########

  plugin :paginate
  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter

  ##############
  # Associations
  ##############

  many_to_one :car

  ###############
  # Class methods
  ###############

  class << self
    def new_with_defaults(car)
      new(date: Date.today, car: car)
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
