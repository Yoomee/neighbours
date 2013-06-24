class NeighbourhoodEmailsController < ApplicationController
  
  load_resource :neighbourhood
  
  before_filter :check_role

  def new
    if @neighbourhood.live?
      params[:subject] = "We have launched in #{@neighbourhood.name}"
      params[:email_body] = @neighbourhood.welcome_email_text
    end
  end
  
  def create
    if params[:subject].blank? || params[:email_body].blank?
      render :action => 'new'
    else
      @neighbourhood.users.where(:role => params[:role]).each do |user|
        email_body = params[:email_body].gsub('<REGISTER_URL>', auth_token_url(user.authentication_token))
        UserMailer.delay.custom_email(user, params[:subject], email_body)
      end
      flash[:notice] = "Sent #{@neighbourhood.users.where(:role => params[:role]).count} emails"
      redirect_to neighbourhoods_path
    end
  end

  private
  def check_role
    raise ActionController::RoutingError.new('Not Found') unless %w{pre_registration group_user}.include?(params[:role])
  end

end