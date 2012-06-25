class OffersController < ApplicationController
  load_and_authorize_resource
  
  def create
    @need = Need.find(params[:need_id])
    @offer.need = @need
    @offer.user = current_user
    @offer.save
  end
end