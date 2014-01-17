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
    UserMailer.new_offer(@offer).deliver if @offer.save
  end

  def destroy_all
    Offer.unscoped.destroy_all(['offers.id IN (?)', params[:ids]])
    flash[:notice] = "Offers successfully destroyed."
    render :nothing => true
  end

  def remove_all
    Offer.where('offers.id IN (?)', params[:ids]).each do |offer|
      unless offer.removed_at.present?
        offer.update_attribute(:removed_at, Time.now)
      end
    end
    flash[:notice] = "Offers successfully deleted."
    render :nothing => true
  end

  def accept
    @offer.update_attribute(:accepted, true)
    UserMailer.accepted_offer(@offer).deliver
    redirect_to @offer.need
  end

  def remove
    @offer.update_attribute(:removed_at, Time.now)
    Post.where(:target_id => @offer.need.id).where('context IS NULL').collect{|post| post.update_attribute(:removed_at, Time.now)}
    UserMailer.remove_offer(@offer).deliver
    flash[:notice] = "Your offer has been withdrawn."
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