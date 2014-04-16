class NeedsController < ApplicationController
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => :show
  
  before_filter :redirect_if_logged_out, :only => :create
  after_filter :set_notifications_to_read, :only => :show
  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @needs = @user.needs.order('created_at DESC')
      @needs_accepted = Need.resolved.where(:user_id => current_user.id).reject{|n| n.is_general_offer_need?}
      @need_chats = Need.unresolved.where(:user_id => current_user.id).joins(:posts).where("posts.context = 'chat'").select{|o| !@needs_accepted.include? o}
      @general_offers_accepted = GeneralOffer.joins(:needs).where('needs.user_id = ?', current_user.id).uniq
      @general_offers_chats = GeneralOffer.where('general_offers.user_id != ?', @user.id).joins(:posts).where('posts.user_id = ?', @user.id).uniq.select{|o| !@general_offers_accepted.include? o}
       #this is wrong
      render :action => "user_index"
    elsif params[:need_category_id].present?
      @needs = Need.where(:category_id => params[:need_category_id]).unresolved.visible_to_user(current_user)
      @needs = current_user.try(:admin?) ? @needs.page(params[:page]) : @needs.random(Need.per_page)
      @needs = @needs.reject{|n|n.is_general_offer_need?}
    else
      @needs = Need.unresolved.order("created_at DESC").visible_to_user(current_user)
      if current_user.try(:admin?) && request.xhr?
        @needs = @needs.page(params[:page])
      elsif current_user
        @needs = @needs.where("needs.user_id != #{current_user.id}")
      end
      @needs = @needs.reject{|n|n.is_general_offer_need?}
    end
  end

  def show
    @need = Need.unscoped.find(params[:id])
    if !can?(:destroy, @need)
      @need = Need.find(params[:id])
    end
    authorize! :show, @need
    @offers = @need.offers
    @chat = params[:context] == 'chat' || @need.posts.where(:context => 'chat').collect(&:user).include?(current_user) || @need.posts.where(:context => 'chat').present? && (@need.user == current_user)
  end

  def new
    if params[:need_category_id]
      @need = Need.new(:category_id => params[:need_category_id])
    else
      @need = Need.new(Need.find_by_id(params[:like]).try(:attributes))
    end
    @need.radius = Need.default_radius
    get_suggest_general_offers
  end
  
  def map
    authorize!(:map, Need)
    @needs_json = Need.with_lat_lng.visible_to_user(current_user).to_json(:only => [:id, :radius], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
  end
  
  def search
    @query = strip_tags(params[:q]).to_s.strip
    if @query.present?
      @needs = Need.search(@query,:page => params[:page], :per_page => 20)
      SearchQuery.create(:query => @query, :user => current_user, :results_count => Need.search_count(@query), :model => "Need")
    else
      @needs = []
    end
    render :action => 'index'
  end

  def create
    @need.user = current_user
    @need.save
    respond_to do |format|
      format.html do
        if @need.valid?
          flash[:notice] = "Created new request for help"
          url_options = current_user.validated? ? {} : {:modal => 'new_need_not_validated'}
          redirect_to user_needs_path(current_user, url_options)
        else
          get_suggest_general_offers
          render :action => 'new'
        end
      end
      format.js do
        if @need.valid?
          render :js => "window.location = '#{params[:return_to].presence || root_path}'"
        end
      end
    end
  end

  def update

  end

  def destroy_all
    Need.unscoped.destroy_all(['id IN (?)', params[:ids]])
    flash[:notice] = "Needs successfully destroyed."
    render :nothing => true
  end

  def remove_all
    Need.where('id IN (?)', params[:ids]).each do |need|
      need.update_attribute(:removed_at, Time.now)
    end
    flash[:notice] = "Needs successfully deleted."
    render :nothing => true
  end
  
  def remove    
    @need.update_attribute(:removed_at, Time.now)
    return_or_redirect_to @need
  end
  
  private
  def get_suggest_general_offers
    if current_user.try(:admin?)
      @suggested_general_offers = GeneralOffer.page(params[:page])
    else
      @suggested_general_offers = GeneralOffer.visible_to_user(current_user).where(['user_id != ?', current_user.try(:id)]).random(GeneralOffer.per_page)
    end
  end
  
  def redirect_if_logged_out
    if current_user.nil? && @need.valid_without_user?
      session[:new_need_attributes] = params[:need]
      return_or_redirect_to(new_registration_path)
    end
  end
  
  def set_notifications_to_read
    @need.read_all_notifications!(current_user) if current_user
  end
end