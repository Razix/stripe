class User < ActiveRecord::Base
  belongs_to :plan
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :stripe_card_token
  # attr_accessible :title, :body
  attr_accessor :stripe_card_token

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(description:email, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      save!
    end
  end
  rescue Stripe::InvalidRequestError => e
  logger.error "Stripe error while creating customer: #{e.mesage}"
  errors.add :base, "There was a problem with your credit card."
end
