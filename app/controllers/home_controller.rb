class HomeController < ApplicationController

  after_filter :set_seen_preregistered_modal, :only => :index
  
  def index
    get_items_for_cycle_columns
    if current_user.try(:has_lat_lng?)
      @needs = Need.unresolved.with_lat_lng.visible_to_user(current_user).without_general_offer_generated.at_least(20)
      @needs_json = @needs.to_json(:current_user => current_user, :only => [:id], :methods => [:lat, :lng, :miles_from_s, :title, :user_first_name])
      @users_json = User.visible_to_user(current_user).to_json(:current_user => current_user, :only => [:id, :lat, :lng, :first_name], :methods => [:miles_from_s])
      @general_offers_json = GeneralOffer.joins(:user).where('users.is_deleted IS FALSE').from_live_neighbourhood.visible_to_user(current_user).to_json(:current_user => current_user, :only => [:id], :methods => [:lat, :lng, :miles_from_s, :title, :user_first_name])
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
      @general_offers = GeneralOffer.joins(:user).where('users.is_deleted IS FALSE').from_live_neighbourhood.visible_to_user(current_user).at_least(20).select{|need| need.removed_at.nil?}
      @helped = Need.resolved.without_general_offer_generated.closest_to(current_user, :with => {:neighbourhood_live => true, :resolved => true}, :limit => 20).at_least(20).select{|need| need.removed_at.nil?} if @general_offers.empty?
      @needs = Need.unresolved.without_general_offer_generated.closest_to(current_user, :with => {:neighbourhood_live => true, :resolved => false}, :without => {:deadline => Need.first.created_at..Time.now}, :limit => 20).at_least(20).select{|need| need.try(:removed_at).nil?}
    else
      @general_offers = GeneralOffer.joins(:user).where('users.is_deleted IS FALSE').from_live_neighbourhood.visible_to_user(current_user).order('created_at DESC').limit(20).at_least(20).select{|need| need.removed_at.nil?}
      @helped = Need.from_live_neighbourhood.resolved.without_general_offer_generated.order('created_at DESC').limit(20).at_least(20).select{|need| need.removed_at.nil?} if @general_offers.empty?
      @needs = Need.from_live_neighbourhood.unresolved.without_general_offer_generated.deadline_in_future.order('created_at DESC').limit(20).at_least(20).select{|need| need.removed_at.nil?}
    end
  end

  def set_seen_preregistered_modal
    session[:seen_preregistered_modal] = true if current_user
  end

end