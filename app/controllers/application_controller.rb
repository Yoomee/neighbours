class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include YmUsers::ApplicationController
  
  before_filter :authenticate, :redirect_to_registration_if_unfinished, :clear_new_need_attributes

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

  def redirect_to_registration_if_unfinished
    return true if current_user.nil? || current_user.is_admin? || %w{registrations sessions}.include?(controller_name)
    path = nil
    if !current_user.has_address?
      path = where_you_live_registration_path(:modal => "address_prompt")
    elsif !current_user.agreed_conditions? || (!current_user.validated? && current_user.validate_by.blank?)
      path = validate_registration_path(:modal => "validation_prompt")
    end
    redirect_to(path) unless path.nil? || current_path == path
  end
    
end
