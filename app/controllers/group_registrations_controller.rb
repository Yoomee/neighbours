class GroupRegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].merge(:role => 'group_user'))
    if @user.save
      sign_in(@user)
      flash[:notice] = 'Thanks for registering!'
      return_or_redirect_to new_group_path
    else
      render :action => 'new'
    end
  end

end