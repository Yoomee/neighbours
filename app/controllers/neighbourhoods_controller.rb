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
      @helped = get_at_least(20, Need.resolved.order(:created_at).reverse_order)
      @need_help = get_at_least(20, Need.unresolved.order(:created_at).reverse_order)
    end
  end
  
  private
  def get_at_least(num, needs_sent)
    needs = needs_sent.dup
    needs.pop if needs.size.odd?
    count = 0
    all_needs = needs
    (num - needs.size).times do |i|
      all_needs << needs[count] if needs[count]
      count = (count >= (needs.size - 1)) ? 0 : count + 1
    end
    all_needs
  end
  
end