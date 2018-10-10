# TODO: Test all error messages nad translate them.
class ServiceEntry < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter

  #############
  # Validations
  #############

  def validate
    super

    validates_presence [
      :title,
      :date,
      :price,
      :expense
    ]
  end

  ###############
  # Class methods
  ###############

  class << self
    def new_with_defaults
      new(date: Date.today)
    end

    def stats
      @stats ||= OpenStruct.new.tap do |o|
        row = db[:service_entries]
              .select(Sequel.lit('count(*)').as(:entries))
              .select_append { sum(:price).as(:price) }
              .select_append { sum(:expense).as(:expenses) }
              .first

        o.entries  = row.fetch(:entries)
        o.price    = row.fetch(:price)
        o.expenses = row.fetch(:expenses)
      end
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
end
