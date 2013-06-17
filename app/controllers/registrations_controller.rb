class RegistrationsController < ApplicationController

  def new
    if params[:redirect_to_needs]
      session[:redirect_to_needs] = true
    end
    if @pre_registration = PreRegistration.find_by_id(session.delete(:pre_registration_id))
      @user = @pre_registration.build_user
      @user.current_step = params[:step]
    else
      #@user = params[:user].present? ? User.new(params[:user]) : User.new(:gender => "male")
      redirect_to root_path
    end
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
            sign_in(@user)
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
              if session.delete(:redirect_to_needs)
                redirect_to(needs_path) and return
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

end