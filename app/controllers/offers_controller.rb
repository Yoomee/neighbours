class OffersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @user = User.find_by_id(params[:user_id]) || current_user    
    @offers = @user.offers.group(:need_id)
    @general_offers = @user.general_offers
  end
  
  def create
    @offer.need = @need = Need.find_by_id(params[:need_id])
    @offer.user = current_user
    @offer.save
    UserMailer.new_offer(@offer).deliver
  end
  
  def accept
    @offer.update_attribute(:accepted, true)
    UserMailer.accepted_offer(@offer).deliver
    redirect_to @offer.need
  end
  
  def reject
    @offer.update_attribute(:accepted, false)
    if @offer.need.posts.first.comments.first
      @offer.need.posts.first.comments.first.destroy if @offer.need.posts.first.comments.first.text == Settings.offer_acceptance_text
    end
    redirect_to @offer.need
  end
end