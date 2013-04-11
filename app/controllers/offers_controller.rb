class OffersController < ApplicationController
  load_and_authorize_resource
  
  def index
    if params[:need_category_id].present?
      @offers = Offer.general_offers.where(:category_id => params[:need_category_id]).random(5)
    else
      @user = User.find_by_id(params[:user_id]) || current_user    
      @offers = @user.offers.group(:need_id)
    end
  end
  
  def new
    @offer = Offer.new(:category_id => params[:need_category_id])
  end
  
  def create
    if @need = Need.find_by_id(params[:need_id])
      @offer.update_attributes(:need => @need, :user => current_user)
      UserMailer.new_offer(@offer).deliver
    else
      @offer.user = current_user
      if @offer.save
        redirect_to thanks_offer_path(@offer)
      else
        render :action => 'new'
      end
    end
  end
  
  def thanks
    
  end
  
  def accept
    @offer.update_attribute(:accepted, true)
    UserMailer.accepted_offer(@offer).deliver
    redirect_to @offer.need
  end
  
  def reject
    @offer.update_attribute(:accepted, false)
    redirect_to @offer.need
  end
end