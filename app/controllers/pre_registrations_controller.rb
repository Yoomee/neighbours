class PreRegistrationsController < ApplicationController  
  load_and_authorize_resource
  
  def create
    if @pre_registration.save
      if @pre_registration.coming_soon?
        render 'coming_soon'
      elsif @pre_registration.live?
        user = @pre_registration.create_user
        logger.debug @pre_registration
        sign_in user
        redirect_to "/neighbourhood"
      else
        #render 'not_in_your_area'  
        render 'coming_soon'
      end  
    else
      render "home/preregister"
    end
  end
  
  
end