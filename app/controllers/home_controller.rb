class HomeController < ApplicationController
  
  def index
  end
  
  def preregister
    if current_user
      redirect_to "/neighbourhood"
    end
  end
  
end