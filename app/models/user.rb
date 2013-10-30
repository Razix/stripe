class User < ActiveRecord::Base
  belongs_to :plan
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  before_save :add_card

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :stripe_card_token, :plan_id
  # attr_accessible :title, :body
  attr_accessor :stripe_card_token

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(description: email, email: email, plan: plan_id, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      save!
    end
  end
  def add_card
    customer = Stripe::Customer.retrieve(self.stripe_customer_token)
    customer.cards.create(card: stripe_card_token)
  end
  rescue Stripe::InvalidRequestError => e
  logger.error "Stripe error while creating customer: #{e.mesage}"
  errors.add :base, "There was a problem with your credit card."
end
