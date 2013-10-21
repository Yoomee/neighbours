class GeneralOffersController < ApplicationController
  
  load_and_authorize_resource :except => :show

  def index
    @general_offers = GeneralOffer.visible_to_user(current_user).where(['user_id != ?', current_user.try(:id)])
    if params[:need_category_id].present?
      @general_offers = @general_offers.where(:category_id => params[:need_category_id])
    end
    @general_offers = current_user.try(:admin?) ? @general_offers.paginate(:page => params[:page], :per_page => 5) : @general_offers.random(5)
  end
  
  def new
    @general_offer.attributes = {:category_id => params[:need_category_id], :radius => GeneralOffer.default_radius}
    get_suggested_needs
  end
  
  def create
    @general_offer.user = current_user
    @general_offer.save
    respond_to do |format|
      format.html do
        if @general_offer.valid?
          redirect_to thanks_general_offer_path(@general_offer)
        else
          get_suggested_needs
          render :action => 'new'
        end
      end
      format.js do
        if @general_offer.valid?
          render :js => "window.location = '#{params[:return_to].presence || root_path}'"
        end
      end
    end
  end
  
  def destroy
    @general_offer.update_attribute(:removed_at, Time.now)
    flash_notice(@general_offer)
    return_or_redirect_to root_path
  end

  def show
    @general_offer = GeneralOffer.unscoped.find(params[:id])
    if @general_offer.removed? && !current_user.try(:admin?)
      raise ActionController::RoutingError.new('Not Found')
    end
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

  private
  def get_suggested_needs
    @suggested_needs = Need.unresolved.visible_to_user(current_user).random(5)
  end
  
end
