class ApplicationController < ActionController::Base
  protect_from_forgery

  include YmUsers::ApplicationController

  before_filter :authenticate, :clear_new_need_attributes, :set_neighbourhood

  AUTH_USERS = { "neighbour" => "maltby123" }

  private
  def authenticate
    return true unless STAGING
    authenticate_or_request_with_http_basic do |username|
      AUTH_USERS[username]
    end
  end

  def clear_new_need_attributes
    if !%w{registrations need sessions pages}.include?(controller_name) || (controller_name == :pages && action_name == :neighbourhood_safety)
      session[:new_need_attributes] = nil
    end
  end
  
  def set_neighbourhood
    if current_user.try(:neighbourhood)
      @neighbourhood = current_user.neighbourhood
    end
  end

end
