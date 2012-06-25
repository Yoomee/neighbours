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
        if new_need_attrs = session.delete(:new_need_attributes)
          @user.needs.create(new_need_attrs)
          redirect_to(needs_path) and return
        else
          redirect_to(root_path) and return
        end
      else
        @user.next_step
      end
    end
    render :action => "new"
  end
  
end