class GeneralOffersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @general_offers = GeneralOffer.visible_to_user(current_user).where(['user_id != ?', current_user.try(:id)])
    if params[:need_category_id].present?
      @general_offers = @general_offers.where(:category_id => params[:need_category_id])
    end
    @general_offers = @general_offers.random(5)
  end
  
  def new
    @general_offer.category_id = params[:need_category_id]
    @suggested_needs = Need.unresolved.visible_to_user(current_user).random(5)
  end
  
  def create
    @general_offer.user = current_user
    if @general_offer.save
      redirect_to thanks_general_offer_path(@general_offer)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @general_offer.destroy
    flash_notice(@general_offer)
    redirect_to(offers_path)
  end
  
  def thanks
    
  end

  def accept
    need_or_error = @general_offer.create_need_for_user(current_user)
    if need_or_error.is_a?(Need)
      UserMailer.accepted_offer(need_or_error.offers.first).deliver
      redirect_to(need_or_error)
    else
      flash[:error] = need_or_error
      redirect_to(@general_offer)
    end
  end
  
end
