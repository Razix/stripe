class PlansController < ApplicationController
  before_filter :root_redirection, only: :show
  def index
    @plans = Plan.order("price")
  end

  def show
    @plan = Plan.find(params[:id])
    authorize! :show, @plan
  end

  private

    def root_redirection
      redirect_to root_path unless current_user
    end
end
