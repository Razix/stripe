class Plan < ActiveRecord::Base
  attr_accessible :name, :price
  has_many :users
  validates :name, presence: true
  validates :price, numericality: { only_integer: true }

  def save_with_plan
    if valid?
      plan = Stripe::Plan.create(amount: price.to_i*100, interval: 'month', name: name, currency: 'usd', id: Plan.last.id.next)
      save!
    end
  end
end
