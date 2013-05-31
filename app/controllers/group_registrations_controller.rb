class GroupRegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].merge(:role => 'group_user'))
    if params[:user][:encrypted_password].present?
      @user.password = 'ignore-this'
      @user.encrypted_password = params[:user][:encrypted_password]
    end
    if @user.save
      sign_in(@user)
      flash[:notice] = 'Thanks for registering!'
      redirect_to new_group_path
    else
      render :action => 'new'
    end
  end

end