class PreRegistrationsController < ApplicationController  
  load_and_authorize_resource
  
  def create
    if @pre_registration.save
      if @pre_registration.coming_soon?
        render 'coming_soon'
      elsif @pre_registration.live?
        render 'live'
      else
        render 'not_in_your_area'  
      end  
    else
      render "home/preregister"
    end
  end
  
  
end