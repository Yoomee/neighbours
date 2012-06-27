class NeedsController < ApplicationController
  load_and_authorize_resource
  
  before_filter :redirect_if_logged_out, :only => :create
  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @needs = @user.needs
      render :action => "user_index"
    else
      @needs = Need.where("user_id != #{current_user.id}").order("created_at DESC").limit(4)
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
      flash[:notice] = "Created new request for help"      
      redirect_to user_needs_path(current_user)
    else
      render :action => 'new'
    end
  end
  
  private
  def redirect_if_logged_out
    if current_user.nil? && @need.valid_without_user?
      session[:new_need_attributes] = params[:need]
      return_or_redirect_to(new_registration_path)
    end
  end
end