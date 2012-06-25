class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include YmUsers::ApplicationController
  
  before_filter :authenticate, :redirect_if_address_not_set, :clear_new_need_attributes

  AUTH_USERS = { "neighbour" => "maltby123" }

  private
  def authenticate
    return true unless Rails.env.production?
    authenticate_or_request_with_http_basic do |username|
      AUTH_USERS[username]
    end
  end

  def clear_new_need_attributes
    if !%w{registrations need}.include?(controller_name)
      session[:new_need_attributes] = nil
    end
  end

  def redirect_if_address_not_set
    return true if current_user.nil? || current_user.is_admin? || current_user.has_address? || %w{registrations sessions}.include?(controller_name)
    address_registration_path = where_you_live_registration_path(:modal => "no_address")
    redirect_to(address_registration_path) unless current_path == address_registration_path
  end
  
end
