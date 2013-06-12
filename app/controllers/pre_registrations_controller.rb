class PreRegistrationsController < ApplicationController  
    
  load_and_authorize_resource
  
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
        UserMailer.admin_message("A new pre-registration", "Yippee! There has been a new pre-registration on the website.", @pre_registration.attributes).deliver
      end  
    end
  end
  
  def destroy_all
    PreRegistration.destroy_all(['id IN (?)', params[:pre_registration_ids]])
    flash[:notice] = "Deleted #{params[:pre_registration_ids].compact.uniq.count} pre-registrations"
    redirect_to map_pre_registrations_path
  end
  
  def show
    @pr = PreRegistration.find(params[:id])
    @email_share_params = "pr=#{@pr.id}"
  end

  def map
    @pre_registrations = PreRegistration.order(:created_at).paginate(:page => params[:page], :per_page => 50)
    @pr_json = PreRegistration.with_lat_lng.to_json(:methods => [:lat_lng])
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