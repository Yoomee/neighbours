class RegistrationsController < ApplicationController
  
  def new
    @user = current_user || User.new
    @user.current_step = params[:step]
  end
  
  def create
    @user = User.find_by_id(params[:user_id]) || User.new
    if @user.update_attributes(params[:user])
      if @user.last_step?
        sign_in(@user)
        redirect_to(root_path) and return
      else
        @user.next_step
      end
    end
    render :action => "new"
  end
  
end