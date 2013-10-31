class RegistrationsController < Devise::RegistrationsController

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
  def update_card
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_token)
    customer.card = params[:user][:stripe_card_token]
    customer.save
    redirect_to edit_user_registration_path, :notice => 'Updated card.'
  end
end