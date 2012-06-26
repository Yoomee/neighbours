class HomeController < ApplicationController
  
  def index
    @needs = Need.order("created_at DESC").limit(4)
    unless current_user
      render :template => "home/logged_out_index"
    end
  end
  
end