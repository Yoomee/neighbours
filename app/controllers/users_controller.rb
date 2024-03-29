class UsersController < ApplicationController

  helper_method :sort_direction

  include YmUsers::UsersController
  load_and_authorize_resource

  def assign_champion
    was_validated = @user.validated
    if @user.update_attributes(params[:user])
      message = was_validated ? "#{@user} has been assigned a neighbourhood champion" : (@user.community_champion ? "#{@user} has been validated and assigned a neighbourhood champion" : "#{@user} has been validated")
      flash[:notice] = message
    else
      flash[:error] = "Something has gone wrong.  Please try again"
    end
    UserMailer.validated(@user).deliver
    redirect_to users_path
  end

  def edit
  end
  
  def inactive
    @months = params[:months].to_i.zero? ? 3 : params[:months].to_i
    @users = User.not_deleted.where("neighbourhood_id IS NOT NULL").where(["current_sign_in_at < ?", @months.months.ago]).where("role != 'pre_registration' OR role IS NULL").order(:last_name, :first_name)
    respond_to do |format|
      format.html {}
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=\"Inactive users (#{@months} months) #{Date.today.strftime('%d-%m-%Y')}.csv\"" 
      end
    end
  end

  def index
    get_users
    
    respond_to do |format|
      format.html {}
      format.xls do
        case params[:users]
        when 'unvalidated'
          @users = @unvalidated_users
        when 'validated'
          @users = @validated_users
        when 'group-users'
          @users = @group_users
        when 'pre-registered'
          @users = @pre_registered_users
        when 'champion-requests'
          @users = @community_champion_requests
        when 'champions'
          @users = @community_champions
        when 'not-in-sheffield'
          @users = @not_in_sheffield
        when 'deleted'
          @users = @deleted_users
        end
        headers["Content-Disposition"] = "attachment; filename=\"Users #{params[:users]} #{Date.today.strftime('%d-%m-%Y')}.xls\""
      end
    end
  end

  def map
    @users_json = User.with_lat_lng.to_json(:only => [:id, :lat, :lng, :house_number, :street_name], :methods => [:full_name])
  end
  
  def search
    user_ids = User.search_for_ids(params[:q])
    get_users(user_ids)
    @results_count = user_ids.size
    render :action => 'index'
  end

  def send_activation_code
    @user = User.find(params[:id])
    @user.update_attribute(:sent_activation_code_at, Time.now)
    redirect_to users_path
  end

  def toggle_is_deleted
    @user.is_deleted = !@user.is_deleted

    dependents = [@user.needs, @user.offers, @user.general_offers, @user.flags, @user.group_invitations, @user.posts]
    dependents.each do |dependent|
      dependent.each{|n|n.update_attributes(:removed_at => @user.is_deleted? ? Time.now : nil)} unless dependent.empty?
    end

    if @user.save
      flash[:notice] = "#{@user} has been #{@user.is_deleted ? 'deleted' : 'undeleted'}" unless @user == current_user  
    else
      flash[:error] = "Something has gone wrong.  Please try again"
    end
    if @user.is_deleted? && @user == current_user
      sign_out(current_user)
      redirect_to root_path
    else
      redirect_to users_path      
    end
  end

  def toggle_champion
    if @user.is_community_champion?
      if @user.update_attributes(:is_community_champion => false)
        User.where(:community_champion_id => @user.id).update_all(:community_champion_id => nil)
        flash[:notice] = "#{@user} is no longer a neighbourhood champion"
      else
        flash[:error] = "Something has gone wrong.  Please try again"
      end
    else
      if @user.update_attributes(:is_community_champion => true, :champion_request_at => nil)
        flash[:notice] = "#{@user} has been made a neighbourhood champion"
      else
        flash[:error] = "Something has gone wrong.  Please try again"
      end
    end
    redirect_to users_path
  end

  def show
    unless current_user.admin?
      if @user.is_deleted?
        redirect_to root_path
        flash[:notice] = "#{@user} has been #{@user.is_deleted ? 'deleted' : 'undeleted'}" unless @user == current_user
      end
    end
  end

  def request_to_be_champion
    @user.update_attribute(:champion_request_at, Time.now)
    UserMailer.community_champion_request(@user).deliver
    flash[:notice] = "You've asked to become a neighbourhood champion. We'll get back to you soon"
    redirect_to @user
  end

  def unvalidate
    if @user.update_attributes(:validated => false)
      flash[:notice] = "#{@user} has been unvalidated"
    else
      flash[:error] = "Something has gone wrong.  Please try again"
    end
    redirect_to users_path
  end

  def update
    attrs = current_user.admin? ? params[:user] : params[:user].slice!(:first_name, :last_name, :house_number, :street_name, :city, :postcode)
    if params[:user][:notes]
      if @user.update_attribute(:notes, params[:user][:notes])
        flash[:notice] = "User notes have been added"
      else
        flash[:error] = "Something has gone wrong.  Please try again"
      end
      redirect_to users_path
    elsif @user.update_attributes(attrs)
      flash[:notice] = "Your profile has been updated"
      redirect_to @user
    else
      render :action => "edit"
    end
  end

  def validate
  end
  
  private
  def get_users(only = nil)
    users = only ? User.where(:id => only) : User.scoped
    if params[:sort] == "champion_request"
      users = users.community_champion_requesters + users.without(users.community_champion_requesters)
    else
      users = params[:sort] && params[:direction] ? users.order("#{params[:sort]} #{sort_direction}") : users.order("created_at desc")
    end
    
    @validated_users = users.not_deleted.validated
    @unvalidated_users = users.not_deleted.unvalidated.where(:role => nil)
    @group_users = users.not_deleted.where(:role => 'group_user')
    @pre_registered_users = users.not_deleted.where(:role => 'pre_registration')
    @community_champion_requests = users.not_deleted.community_champion_requesters
    @community_champions = users.not_deleted.community_champions
    @not_in_sheffield = users.not_in_sheffield
    @deleted_users = users.deleted
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end