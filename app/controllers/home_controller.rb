class HomeController < ApplicationController
  
  def index
    if current_user
      render :template => "wireframes/logged_in_home"
    end
  end
  
end