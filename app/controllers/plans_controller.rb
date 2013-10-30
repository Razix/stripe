class PlansController < ApplicationController
  before_filter :root_redirection, only: :show
  respond_to :html, :json

  def index
    @plans = Plan.order("price")
  end

  def show
    @plan = Plan.find(params[:id])
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

  private

    def root_redirection
      redirect_to root_path unless current_user
    end
end
