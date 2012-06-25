class NeedsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @needs = @user.needs
    end
  end

  def new
  end

  def create
    #@need = Need.new(params[:need].merge(:user => current_user))
    @need.user = current_user
    if @need.save      
      redirect_to needs_path
    else
      render :action => 'new'
    end
  end
end