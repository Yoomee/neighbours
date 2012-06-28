class UsersController < ApplicationController
  include YmUsers::UsersController
  load_and_authorize_resource
  
  def index
    @validated_users = User.validated
    @unvalidated_users = User.unvalidated
    @search_queries = SearchQuery.order("created_at DESC")
  end
  
  def validate
    @user.update_attribute(:validated,true)
    flash[:notice] = "#{@user} has been validated"
    redirect_to users_path
  end
end