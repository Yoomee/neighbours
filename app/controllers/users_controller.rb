class UsersController < ApplicationController
  include YmUsers::UsersController
  load_and_authorize_resource
  
  def assign_champion
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user} has been validated, with #{User.find_by_id(params[:user][:community_champion_id])} assigned as community champion"
    else
      flash[:error] = "Something has gone wrong.  Please try again"
    end
    redirect_to users_path
  end
  
  def edit
  end
  
  def index
    @validated_users = User.validated
    @unvalidated_users = User.unvalidated
    @community_champions = User.community_champions
    @community_champion_requests = User.community_champion_requesters
  end
  
  def toggle_champion
    if @user.is_community_champion?
      if @user.update_attributes(:is_community_champion => false)
        User.where(:community_champion_id => @user.id).update_all(:community_champion_id => nil)
        flash[:notice] = "#{@user} is no longer a community champion"
      else
        flash[:error] = "Something has gone wrong.  Please try again"
      end
    else
      if @user.update_attributes(:is_community_champion => true, :champion_request_at => nil)
        flash[:notice] = "#{@user} has been made a community champion"
      else
        flash[:error] = "Something has gone wrong.  Please try again"
      end
    end
    redirect_to users_path    
  end
  
  def show    
  end

  def request_to_be_champion
    @user.update_attribute(:champion_request_at, Time.now)
    flash[:notice] = "You've asked to become a community champion"
    redirect_to @user
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your profile has been updated"
      redirect_to @user
    else
      render :action => "edit"
    end
  end
  
  def validate
  end
end