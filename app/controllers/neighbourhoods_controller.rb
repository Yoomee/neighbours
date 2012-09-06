class NeighbourhoodsController < ApplicationController
  load_and_authorize_resource
  
  def show
    if current_user && !current_user.is_in_maltby?
      params[:id] = "other_neighbourhood"
      @enquiry = Enquiry.new(:form_name => "other_neighbourhood", :first_name => current_user.first_name, :last_name => current_user.last_name, :email => current_user.email)
      render :template => "enquiries/new"
    else    
      if current_user
        @needs_json = Need.unresolved.with_lat_lng.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
      else
        @needs_json = []
      end
      @helped = Need.resolved.limit(4)
      @need_help = Need.unresolved.limit(7)
    end
  end
  
end