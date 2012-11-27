class NeedsController < ApplicationController
  load_and_authorize_resource
  
  before_filter :redirect_if_logged_out, :only => :create
  after_filter :set_notifications_to_read, :only => :show
  
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @needs = @user.needs.order('created_at DESC')
      render :action => "user_index"
    else
      @needs = current_user ? Need.unresolved.where("user_id != #{current_user.id}").visible_to_user(current_user).order("created_at DESC") : Need.unresolved.order("created_at DESC")
    end
  end

  def show
    @offers = @need.offers
  end

  def new
    if params[:need_category_id]
      @need = Need.new(:category_id => params[:need_category_id])
    else
      @need = Need.new(Need.find_by_id(params[:like]).try(:attributes))
    end
    @need.radius = Need.default_radius
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
    if @need.save
      flash[:notice] = "Created new request for help"      
      redirect_to user_needs_path(current_user)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @need.destroy
    return_or_redirect_to needs_path
  end
  
  private
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