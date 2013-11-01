class PlansController < ApplicationController
  before_filter :root_redirection, only: :show
  before_filter :load_customer, only: [:show, :update_plan]
  respond_to :html, :json

  def index
    @plans = Plan.order("price")
  end

  def show
    @plan = Plan.find(params[:id])
    @subscription = @customer.subscription
    authorize! :show, @plan
  end

  def new
    @plan = Plan.new
    respond_with @plan
  end

  def create
    @plan = Plan.new(params[:plan])
    flash[:notice] = 'Plan was successfully created.' if @plan.save_with_plan
    respond_with @plan
  end

  def update_plan
    current_user.update_attributes(plan_id: params[:plan][:id])
    @customer.update_subscription(plan: current_user.plan.id)
    invoice = Stripe::Invoice.create(customer: @customer.id)
    invoice.pay
    redirect_to root_path, notice: 'Plan is updated.'
  end

  def cancel_subscription
    current_user.terminate_subscription
    current_user.update_attributes(plan_id: nil)
    redirect_to plan_path(current_user.plan), notice: 'Unsubscribed'
  end

  private

    def root_redirection
      redirect_to root_path unless current_user && current_user.plan
    end

    def load_customer
      @customer = Stripe::Customer.retrieve(current_user.stripe_customer_token)
    end
end
