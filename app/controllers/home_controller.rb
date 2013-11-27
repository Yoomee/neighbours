class HomeController < ApplicationController
  
  def index
    get_items_for_cycle_columns
    if current_user.try(:has_lat_lng?)
      needs = Need.unresolved.with_lat_lng.visible_to_user(current_user)
      @needs_json = needs.to_json(:current_user => current_user, :only => [:id], :methods => [:lat, :lng, :miles_from_s, :title, :user_first_name])
      @users_json = User.visible_to_user(current_user).to_json(:current_user => current_user, :only => [:id, :lat, :lng, :first_name], :methods => [:miles_from_s])
      @general_offers_json = GeneralOffer.from_live_neighbourhood.visible_to_user(current_user).to_json(:current_user => current_user, :only => [:id], :methods => [:lat, :lng, :miles_from_s, :title, :user_first_name])
    else
      @needs_json ||= []
      @users_json ||= []
    end
    @slideshow = Slideshow.find_by_slug(:homepage_slideshow)
  end
  
  def preregister
    if current_user
      redirect_to "/neighbourhood"
    end
  end
  
  private
  def get_items_for_cycle_columns
    lat, lng = Need.get_lat_lng_from_postcode(params[:postcode]) if params[:postcode]
    if current_user.try(:has_lat_lng?)
      @general_offers = GeneralOffer.from_live_neighbourhood.visible_from_location(current_user.lat, current_user.lng, :order_by_closest => true, :limit => 20).at_least(20)
      @helped = Need.closest_to(current_user, :with => {:neighbourhood_live => true, :resolved => true}, :limit => 20).at_least(20) if @general_offers.empty?
      @needs = Need.closest_to(current_user, :with => {:neighbourhood_live => true, :resolved => false}, :without => {:deadline => Need.first.created_at..Time.now}, :limit => 20).at_least(20)
    else
      @general_offers = GeneralOffer.from_live_neighbourhood.visible_to_user(current_user).order('created_at DESC').limit(20).at_least(20)
      if params[:postcode]
        @helped = Need.visible_from_location(lat, lng, :maximum_radius => 5).from_live_neighbourhood.resolved.order('created_at DESC').limit(20).at_least(20) if @general_offers.empty?
      else
        @helped = Need.from_live_neighbourhood.resolved.order('created_at DESC').limit(20).at_least(20) if @general_offers.empty?
      end
      @needs = Need.from_live_neighbourhood.unresolved.deadline_in_future.order('created_at DESC').limit(20).at_least(20)
    end
  end
  
end