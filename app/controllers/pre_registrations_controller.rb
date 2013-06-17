class PreRegistrationsController < ApplicationController  
  
  def create
    @pre_register_user = User.new(params[:user].merge(:role => 'pre_registration'))
    if @pre_register_user.pre_register_need_or_offer_valid? && @pre_register_user.save
      if @pre_register_user.neighbourhood && @pre_register_user.neighbourhood.live? 
        session[:pre_register_user_id] = @pre_register_user.id
        render :js => "window.location = '#{new_registration_path}'"
      else
        UserMailer.pre_register_thank_you(@pre_register_user).deliver
        UserMailer.admin_message("A new pre-registration", "Yippee! There has been a new pre-registration on the website.", @pre_register_user.attributes).deliver
        if @pre_register_user.neighbourhood
          render :js => "window.location = '#{neighbourhood_path(@pre_register_user.neighbourhood)}'"
        else          
          render :js => "window.location = '#{pre_registration_path(@pre_register_user)}'"
        end
      end
    end
  end
  
  def destroy_all
    PreRegistration.destroy_all(['id IN (?)', params[:pre_registration_ids]])
    flash[:notice] = "Deleted #{params[:pre_registration_ids].compact.uniq.count} pre-registrations"
    redirect_to map_pre_registrations_path
  end
  
  def show
    @pre_register_user = User.find(params[:id])
    @email_share_params = "pr=#{@pre_register_user.id}"
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