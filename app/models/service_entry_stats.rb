class ServiceEntryStats
  attr_accessor :entries
  attr_accessor :price
  attr_accessor :expenses

  def initialize
    self.entries  = 0
    self.price    = 0
    self.expenses = 0

    perform if calculate?
  end

  def calculate?
    ServiceEntry.count > 1
  end

  private

  def perform
    entries = ServiceEntry.dataset

    self.entries  = entries.count
    self.price    = entries.sum(:price)
    self.expenses = entries.sum(:expense)
  end
end
