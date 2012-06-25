class HomeController < ApplicationController
  
  def index
    unless current_user
      render :template => "home/logged_out_index"
    end
  end
  
end