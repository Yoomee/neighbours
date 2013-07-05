class HomeController < ApplicationController
  
  def index
    @general_offers = GeneralOffer.visible_to_user(current_user).order(:created_at).reverse_order.at_least(20)
    @helped = Need.from_live_neighbourhood.resolved.order(:created_at).reverse_order.at_least(20) if @general_offers.empty?
    @needs = Need.from_live_neighbourhood.unresolved.deadline_in_future.order(:created_at).reverse_order.at_least(20)
    @general_offers_json = @general_offers.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])    
    if current_user.try(:has_lat_lng?)
      needs = Need.unresolved.with_lat_lng.visible_to_user(current_user)
      @needs_json = needs.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
      @users_json = User.visible_to_user(current_user).to_json(:only => [:id, :lat, :lng, :street_name, :first_name])
    else
      @needs_json ||= []
      @users_json ||= []
    end
  end
  
  def preregister
    if current_user
      redirect_to "/neighbourhood"
    end
  end
  
end