class RegistrationsController < ApplicationController

  skip_before_filter :clear_pre_register_user_id

  before_filter :get_user

  def new
    if params[:redirect_to_needs]
      session[:redirect_to_needs] = true
    end
    @user.current_step = @user.steps.first
  end

  def create
    @user.attributes = params[:user].merge(:role => nil)
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
            send_emails
            sign_in(@user)
            if @user.validate_by == "post" && !@user.validated?
              flash[:modal] = {:title => "Thanks for registering", :text => "We'll send you a letter with a unique code and instructions on how to validate your account."}
            end
            if new_need_attrs = session.delete(:new_need_attributes)
              @user.needs.create(new_need_attrs)
              flash[:notice] = "Congratulations! You have added your first request. Once we've validated your account then neighbours can help you."
            elsif session.delete(:redirect_to_needs)
              flash[:notice] = "Congratulations! You've just registered. Once we've validated your account you'll be able to help your neighbours."
            end
            redirect_to(Page.find_by_slug(:what_next) || root_path) and return
          else
            flash[:error] = "Something's gone wrong - sorry. Please try again"
            redirect_to(new_registration_path) and return
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

  private
  def get_user
    unless @user = User.find_by_id(session[:pre_register_user_id])
      raise CanCan::AccessDenied
    end
  end

  def send_emails
    if @user.validate_by == "post"
      UserMailer.new_registration_with_post_validation(@user).deliver
    elsif @user.validate_by == "organisation"
      UserMailer.new_registration_with_organisation_validation(@user).deliver
    end
    UserMailer.admin_message("A new user has just registered on the site", "You will be delighted to know that a new user has just registered on the site.\n\nHere are all the gory details:", @user.attributes).deliver
  end

end