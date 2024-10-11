class ServiceEntryStats
  attr_accessor :dataset
  attr_accessor :entries
  attr_accessor :price
  attr_accessor :expenses

  def initialize(dataset)
    self.dataset = dataset

    self.entries  = 0
    self.price    = 0
    self.expenses = 0

    perform if calculate?
  end

  def calculate?
    dataset.count > 1
  end

  private

  def perform
    self.entries  = dataset.count
    self.price    = dataset.sum(:price)
    self.expenses = dataset.sum(:expense)
  end
end
