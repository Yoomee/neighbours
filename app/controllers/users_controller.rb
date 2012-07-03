class UsersController < ApplicationController
  include YmUsers::UsersController
  load_and_authorize_resource
  
  def edit
  end
  
  def index
    @validated_users = User.validated
    @unvalidated_users = User.unvalidated
    @search_queries = SearchQuery.order("created_at DESC")
  end
  
  def show    
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