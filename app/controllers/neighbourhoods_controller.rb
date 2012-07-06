class NeighbourhoodsController < ApplicationController
  
  def show
    @needs_json = Need.unresolved.with_lat_lng.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
    @helped = Need.resolved.limit(4)
    @need_help = Need.unresolved.limit(4)
  end
  
end