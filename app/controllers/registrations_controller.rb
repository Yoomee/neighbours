class RegistrationsController < ApplicationController

  def new
    if params[:redirect_to_needs]
      session[:redirect_to_needs] = true
    end
    if @pre_registration = PreRegistration.find_by_id(session.delete(:pre_registration_id))
      @user = @pre_registration.create_user
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
      debugger
      if @user.valid?
        if @user.last_step?
          begin
            if @user.save
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
          rescue CreditCardPreauthFailedError
            @user.errors.add(:validate_by, "Unfortunately we couldn't verify your address from the card details you entered. Please enter some different card details or select an alternative option below.")
            @user.credit_card_preauths.build
          end
        else
          @user.next_step!
          @user.credit_card_preauths.build if @user.validation_step?
        end
      else
        #@user not valid
      end
    end
    render :action => "new"
  end

end