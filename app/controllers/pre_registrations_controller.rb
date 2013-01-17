class PreRegistrationsController < ApplicationController  
  load_and_authorize_resource :only => :create
  
  def create
    if @pre_registration.save
      if @pre_registration.coming_soon?
        @redirect_url = "/area/#{@pre_registration.neighbourhood.id}-#{@pre_registration.neighbourhood.name.parameterize}"
      elsif @pre_registration.live?
        user = @pre_registration.create_user
        sign_in user
        @redirect_url = "/neighbourhood"
      else
        @redirect_url = "/pr/#{@pre_registration.id}"
      end  
    end
  end
  
  def show
    @pr = PreRegistration.find(params[:id])
  end

  
  
end