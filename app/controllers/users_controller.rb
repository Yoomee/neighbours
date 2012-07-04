class UsersController < ApplicationController
  include YmUsers::UsersController
  load_and_authorize_resource
  
  def edit
  end
  
  def index
    @validated_users = User.validated
    @unvalidated_users = User.unvalidated
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
    @user.update_attribute(:validated,true)
    flash[:notice] = "#{@user} has been validated"
    redirect_to users_path
  end
end