class ApplicationController < ActionController::Base
  protect_from_forgery

  include YmUsers::ApplicationController

  before_filter :authenticate, :clear_new_need_attributes, :set_neighbourhood, :clear_pre_register_user_id, :sign_out_pre_registered_user

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

  def clear_pre_register_user_id
    session.delete(:pre_register_user_id)
  end
  
  def set_neighbourhood
    if current_user.try(:neighbourhood)
      @neighbourhood = current_user.neighbourhood
    end
  end

  def sign_out_pre_registered_user
    return true unless current_user.try(:role_is?, 'pre_registration')
    user = current_user
    sign_out(current_user)
    if params[:controller] == 'group_registrations'
      session[:pre_register_user_id] = user.id
      flash.delete(:notice)
      redirect_to new_group_registration_path
    elsif user.neighbourhood.try(:live?)
      session[:pre_register_user_id] = user.id
      flash.delete(:notice)
      redirect_to new_registration_path
    elsif user.neighbourhood
      redirect_to user.neighbourhood
    else
      redirect_to pre_registration_path(user)
    end
  end

end