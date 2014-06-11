class GeneralOffersController < ApplicationController
  
  load_and_authorize_resource :except => :show
  after_filter :set_notifications_to_read, :only => :show

  def index
    @general_offers = GeneralOffer.visible_to_user(current_user).where(['user_id != ?', current_user.try(:id)])
    if params[:need_category_id].present?
      @general_offers = @general_offers.where(:category_id => params[:need_category_id])
    end
    @general_offers = current_user.try(:admin?) ? @general_offers.page(params[:page]) : @general_offers.random(GeneralOffer.per_page)
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

  def destroy_all
    GeneralOffer.unscoped.destroy_all(['id IN (?)', params[:ids]])
    flash[:notice] = "General offers successfully destroyed."
    render :nothing => true
  end

  def remove_all
    GeneralOffer.where('id IN (?)', params[:ids]).each do |need|
      need.update_attribute(:removed_at, Time.now)
    end
    render :nothing => true
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
    @chat = params[:context] == 'chat' || @general_offer.posts.where(:context => 'chat').collect(&:user).include?(current_user) || @general_offer.posts.where(:context => 'chat').present? && (@general_offer.user == current_user)
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
    @suggested_needs = Need.unresolved.visible_to_user(current_user).without_general_offer_generated
    @suggested_needs = current_user.try(:admin?) ? @suggested_needs.order("created_at DESC") : @suggested_needs.order_by_rand(seed: session[:seed])
    @suggested_needs = @suggested_needs.reject{|n|n.is_general_offer_need?}

    @suggested_needs = WillPaginate::Collection.create(params[:page] || 1, Need.per_page) do |pager|
      pager.replace(@suggested_needs[pager.offset, pager.per_page])

      unless pager.total_entries
        pager.total_entries = @suggested_needs.count
      end
    end
  end

  def set_notifications_to_read
    @general_offer.read_all_notifications!(current_user) if current_user
  end
  
end
