class OffersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @user = User.find_by_id(params[:user_id]) || current_user    
    @offers = @user.offers.group(:need_id)
  end
  
  def create
    @need = Need.find(params[:need_id])
    @offer.need = @need
    @offer.user = current_user
    @offer.save
  end
end