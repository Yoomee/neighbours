class RegistrationsController < ApplicationController

  before_filter :get_user
  before_filter :build_organisation_as_admin

  def new
    @user.current_step = @user.group_user? ? @user.steps[1] : @user.steps[0]
  end

  def create
    if params[:user][:organisation_as_admin_attributes].nil? && @user.organisation_as_admin
      #Pre-registered organisation changes their mind and decides to be a normal user but doesn't have a live area
      if @user.neighbourhood && @user.neighbourhood.live?
        @user.organisation_as_admin.destroy
      else
        redirect_to(pre_registration_path(@user)) and return
      end
    end

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
            @user.update_attribute(:organisation_id, @user.organisation_as_admin.id) if @user.organisation_as_admin.valid?
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
    @organisation_name = params[:user][:organisation_as_admin_attributes][:name] if params[:user][:organisation_as_admin_attributes].present?
    render :action => "new"
  end

  private
  def build_organisation_as_admin
    if params[:user].nil? || !params[:user].try(:[], 'organisation_as_admin_attributes').present?
      @user.build_organisation_as_admin
    end
  end

  def get_user
    @user = current_user
    if (@user && %w{pre_registration group_user}.include?(@user.role) && @user.neighbourhood) || @user.pre_registered_organisation?
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