class User < ActiveRecord::Base
  belongs_to :plan
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :stripe_card_token, :plan_id, :coupon
  # attr_accessible :title, :body
  attr_accessor :stripe_card_token, :coupon
  before_destroy :terminate_subscription

  def save_with_payment
    if valid?
      if coupon.present?
        customer = Stripe::Customer.create(description: email, email: email, plan: plan_id, card: stripe_card_token, coupon: coupon)
      else
        customer = Stripe::Customer.create(description: email, email: email, plan: plan_id, card: stripe_card_token)
      end
      self.stripe_customer_token = customer.id
      save!
    end
    rescue Stripe::StripeError => e
      logger.error "Stripe Error: " + e.message
      errors.add :base, "#{e.message}."
      false
  end

  def terminate_subscription
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    customer.cancel_subscription if customer.subscription.status == 'active'
  end

  def subscribed?
    customer = Stripe::Customer.retrieve(stripe_customer_token)
    customer.subscription.present?
  end

  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.mesage}"
    errors.add :base, "There was a problem with your credit card."
end
