class GeneralOffersController < ApplicationController
  load_and_authorize_resource
  
  def index
    if params[:need_category_id].present?
      @general_offers = GeneralOffer.where(:category_id => params[:need_category_id]).random(5)
    else
      @general_offers = GeneralOffer.random(5)
    end
  end
  
  def new
    @general_offer.category_id = params[:need_category_id]
  end
  
  def create
    @general_offer.user = current_user
    if @general_offer.save
      redirect_to thanks_general_offer_path(@general_offer)
    else
      render :action => 'new'
    end
  end
  
  def thanks
    
  end
  
end
