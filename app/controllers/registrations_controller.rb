class RegistrationsController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.find_by_id(params[:user_id]) || User.new
    if @user.update_attributes(params[:user])
      @user.next_step
    end
    if @user.last_step?
      redirect_to "wireframes/logged_in_home"
    else
      render :action => "new"
    end
  end
  
end