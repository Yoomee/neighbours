class RegistrationsController < ApplicationController

  before_filter :get_user

  def new
    @user.current_step = @user.group_user? ? @user.steps[1] : @user.steps[0]
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
            sign_in(@user, :bypass => true)
            if @user.validate_by == "post" && !@user.validated?
              flash[:modal] = {:title => "Thanks for registering", :text => "We'll send you a letter with a unique code and instructions on how to validate your account."}
            end
            if new_need_attrs = session.delete(:new_need_attributes)
              need = @user.needs.create(new_need_attrs)
              flash[:notice] = "Congratulations! You have added your first request."
              flash[:notice] += " Once we've validated your account then neighbours can help you." if !@user.validated?
              redirect_to(need) and return
            else
              flash[:notice] = "Congratulations! You've just registered."
              flash[:notice] += " Once we've validated your account you'll be able to help your neighbours." if !@user.validated?              
              if params[:return_to].present?
                redirect_to(params[:return_to]) and return
              elsif !@user.validated && what_next_page = Page.find_by_slug(:what_next)
                flash.delete(:notice)
                redirect_to(what_next_page) and return
              else
                redirect_to(root_path) and return
              end
            end
          else
            flash[:error] = "Something's gone wrong - sorry. Please try again"
            redirect_to(new_registration_path) and return
          end
        else
          @user.next_step!
        end
      else
        #@user not valid
        @user.credit_card_preauth.try(:deliver_failure_email)
      end
    end
    render :action => "new"
  end

  private
  def get_user
    @user = current_user
    if %w{pre_registration group_user}.include?(@user.role) && @user.try(:neighbourhood)
      @user.last_name = nil if @user.last_name == '_BLANK_'
    else      
      raise CanCan::AccessDenied
    end
  end

  def send_emails
    UserMailer.new_registration(@user).deliver
    UserMailer.admin_message("A new user has just registered on the site", "You will be delighted to know that a new user has just registered on the site.\n\nHere are all the gory details:", @user.attributes).deliver
  end

end