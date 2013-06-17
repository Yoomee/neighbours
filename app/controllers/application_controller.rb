class ApplicationController < ActionController::Base
  protect_from_forgery

  include YmUsers::ApplicationController

  before_filter :authenticate, :clear_new_need_attributes, :set_neighbourhood, :clear_pre_register_user_id

  AUTH_USERS = { "neighbour" => "maltby123" }

  def after_sign_in_path_for(user)
    if user.role_is?('pre_registration')
      sign_out(user)      
      session[:pre_register_user_id] = user.id
      flash.delete(:notice)
      new_registration_path
    else
      params.delete(:next) || super
    end
  end

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

  def clear_pre_register_user_id
    session.delete(:pre_register_user_id)
  end
  
  def set_neighbourhood
    if current_user.try(:neighbourhood)
      @neighbourhood = current_user.neighbourhood
    end
  end

end
