class RegistrationsController < Devise::RegistrationsController
  before_filter :load_customer, only: [:edit, :update_card, :update_plan]

  def new
    @plan = Plan.find(params[:plan_id])
    build_resource({plan_id: @plan.id})
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)

    if resource.save_with_payment
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, location: plan_path(current_user.plan)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def edit
    @card = @customer.cards.first
    @subscription = @customer.subscription
    render :edit
  end

  def update_card
    @customer.card = params[:user][:stripe_card_token]
    @customer.save
    redirect_to edit_user_registration_path, notice: 'Card is updated.'
  end

  def update_plan
    if current_user.update_attributes(params[:user])
      @customer.update_subscription(plan: current_user.plan.id)
      redirect_to edit_user_registration_path, notice: 'Plan is updated.'
    end
  end

  def cancel_subscription
    current_user.terminate_subscription
    current_user.update_attributes(plan_id: nil)
    redirect_to edit_user_registration_path, notice: 'Unsubscribed'
  end

  private

    def load_customer
      @customer = Stripe::Customer.retrieve(current_user.stripe_customer_token)
    end

end