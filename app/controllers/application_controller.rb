class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include YmUsers::ApplicationController
  
  before_filter :authenticate, :redirect_if_address_not_set, :clear_new_need_attributes

  AUTH_USERS = { "neighbour" => "maltby123" }

  def after_sign_in_path_for_with_neighbours(resource_or_scope)
    if new_need_attrs = session.delete(:new_need_attributes)
      resource_or_scope.needs.create(new_need_attrs)
      needs_path
    else
      after_sign_in_path_for_without_neighbours(resource_or_scope)
    end
  end
  alias_method_chain :after_sign_in_path_for, :neighbours

  private
  def authenticate
    return true unless Rails.env.production?
    authenticate_or_request_with_http_basic do |username|
      AUTH_USERS[username]
    end
  end

  def clear_new_need_attributes
    if !%w{registrations need sessions}.include?(controller_name)
      session[:new_need_attributes] = nil
    end
  end

  def redirect_if_address_not_set
    return true if current_user.nil? || current_user.is_admin? || current_user.has_address? || %w{registrations sessions}.include?(controller_name)
    address_registration_path = where_you_live_registration_path(:modal => "no_address")
    redirect_to(address_registration_path) unless current_path == address_registration_path
  end
  
end
