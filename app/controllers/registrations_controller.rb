class RegistrationsController < ApplicationController

  def new
    if params[:redirect_to_needs]
      session[:redirect_to_needs] = true
    end
    @user = params[:user].present? ? User.new(params[:user]) : User.new(:gender => "male")
    @user.current_step = params[:step]
  end

  def create
    @user = User.new(params[:user])
    if params[:user][:encrypted_password].present?
      @user.password = 'ignore-this'
      @user.encrypted_password = params[:user][:encrypted_password]
    end
    if params[:back]
      @user.previous_step!
    else
      if @user.valid?
        if @user.last_step?
          if @user.save
            if @user.is_in_maltby?
              if @user.validate_by == "post" && !@user.validated?
                flash[:modal] = {:title => "Thanks for registering", :text => "We'll send you a letter with a unique code and instructions on what to do next."}
              end
              if new_need_attrs = session.delete(:new_need_attributes)
                @user.needs.create(new_need_attrs)
                flash[:notice] = "Congratulations! You have added your first request. Once we've validated your account then neighbours can help you."
                redirect_to(page_path(Page.find_by_slug(:what_next))) and return
              elsif session.delete(:redirect_to_needs)
                flash[:notice] = "Congratulations! You've just registered. Once we've validated your account you'll be able to help your neighbours."
                redirect_to(page_path(Page.find_by_slug(:what_next))) and return
              else
                redirect_to(page_path(Page.find_by_slug(:what_next))) and return
              end
            else
              flash[:notice] = "Congratulations! You've just registered. We'll contact you once Neighbours Can Help is available in your area."
              redirect_to(page_path(Page.find_by_slug(:what_next))) and return
            end
          else
            flash[:error] = "Something's gone wrong - sorry.  Please try again"
            redirect_to new_registration_path and return
          end
        else
          @user.next_step!
        end
      else
        #@user not valid
      end
    end
    render :action => "new"
  end

end