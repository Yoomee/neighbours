class RegistrationsController < ApplicationController
  
  def new
    if params[:redirect_to_needs]
      session[:redirect_to_needs] = true
    end
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
          flash[:notice] = "Congratulations! You have added your first request. Once we've validated your account then neighbours can help you."
          redirect_to(user_needs_path(current_user)) and return
        elsif session.delete(:redirect_to_needs)
          flash[:notice] = "Congratulations! You've just registered. Once we've validated your account you'll be able to help your neighbours."
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