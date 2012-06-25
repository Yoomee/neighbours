class NeedsController < ApplicationController
  load_and_authorize_resource
  
  before_filter :redirect_if_logged_out, :only => :create
  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @needs = @user.needs
    end
  end

  def show
    @offers = @need.offers
    @offer = Offer.new
  end

  def new
  end

  def create
    @need.user = current_user
    if @need.save      
      redirect_to needs_path
    else
      render :action => 'new'
    end
  end
  
  private
  def redirect_if_logged_out
    if current_user.nil? && @need.valid_without_user?
      session[:new_need_attributes] = params[:need]
      redirect_to new_registration_path
    end
  end
end