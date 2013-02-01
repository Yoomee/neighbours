class PreRegistrationsController < ApplicationController  
    
  load_and_authorize_resource :only => :create
  
  def create
    if @pre_registration.save
      session[:email]=@pre_registration.email
      if @pre_registration.coming_soon?
        @redirect_url = "/area/#{@pre_registration.neighbourhood.id}-#{@pre_registration.neighbourhood.name.parameterize}"
        UserMailer.preregister_thank_you(@pre_registration).deliver
      elsif @pre_registration.live?
        if User.find_by_email(@pre_registration.email.downcase).present?
          flash[:notice] = "An account with this email address already exits. Sign in here."
          @redirect_url = "/login"
        else
          session[:pre_registration_id] = @pre_registration.id
          @redirect_url = "/registrations/new"
        end
      else
        @redirect_url = "/pr/#{@pre_registration.id}"
        UserMailer.preregister_thank_you(@pre_registration).deliver    
      end  
    end
  end
  
  def show
    @pr = PreRegistration.find(params[:id])
    @email_share_params = "pr=#{@pr.id}"
  end

  def map
    @pr_json = PreRegistration.all.select{|pr| pr.lat_lng.present?}.to_json(:methods => [:lat_lng])
  end
  
  def index
    respond_to do |format|
      format.html do
        redirect_to map_pre_registrations_path
      end
      format.xls do
        @pre_registrations = PreRegistration.all
      end
    end
  end
  
end