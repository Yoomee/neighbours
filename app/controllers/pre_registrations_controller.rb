class PreRegistrationsController < ApplicationController
  
  def create
    @pre_register_user = params[:user][:organisation_as_admin_attributes].present? ? User.new(params[:user].merge(:role => 'pre_registered_organisation')) : User.new(params[:user].merge(:role => 'pre_registration'))
    if @pre_register_user.save
      sign_in(@pre_register_user)
      UserMailer.pre_register_thank_you(@pre_register_user).deliver
      UserMailer.admin_message("A new pre-registration", "Yippee! There has been a new pre-registration on the website.", @pre_register_user.attributes).deliver
      if (@pre_register_user.neighbourhood && @pre_register_user.neighbourhood.live?) || @pre_register_user.pre_registered_organisation?
        @next_url = new_registration_path
      elsif @pre_register_user.neighbourhood
        @next_url = neighbourhood_path(@pre_register_user.neighbourhood)
      else
        @next_url = pre_registration_path(@pre_register_user)
      end

      unless @pre_register_user.pre_registered_organisation?
        @need = @pre_register_user.needs.build
        @general_offer = @pre_register_user.general_offers.build
      end
    end
  end

  def about

  end
  
  def destroy_all
    User.where(:role => 'pre_registration').destroy_all(['id IN (?)', params[:user_ids]])
    flash[:notice] = "Deleted #{params[:user_ids].compact.uniq.count} pre-registered users"
    redirect_to map_pre_registrations_path
  end
  
  def show
    @pre_register_user = User.find(params[:id])
    @email_share_params = "pr=#{@pre_register_user.id}"
  end

  def map
    @pre_registered_users = User.not_deleted.where(:role => 'pre_registration').order(:created_at).paginate(:page => params[:page], :per_page => 50)
    @pr_json = User.not_deleted.where(:role => 'pre_registration').with_lat_lng.to_json(:methods => [:lat_lng, :full_name, :area])
  end
  
  def index
    respond_to do |format|
      format.html do
        redirect_to map_pre_registrations_path
      end
      format.xls do
        @pre_registered_users = User.where(:role => 'pre_registration')
      end
    end
  end
  
end