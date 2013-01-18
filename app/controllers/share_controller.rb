class ShareController < ApplicationController
  
  def email_form
    if params[:neighbourhood]
      @neighbourhood = Neighbourhood.find(params[:neighbourhood])
      @area = @neighbourhood.name 
      @link = "http://#{request.host}/area/#{@neighbourhood.id}-#{@neighbourhood.name.parameterize}"
    end
    if params[:pr]
      @pr = PreRegistration.find(params[:pr]) 
      @area = @pr.area 
      @link = "http://#{request.host}/pr/#{@pr.id}"
    end
    if session[:email] 
      @from = session[:email] 
    end
  end
  
  def send_email
    @send_again_url = params[:email][:send_again_url]
    session[:email] = params[:email][:from]
    UserMailer.send_invite(params[:email][:from], params[:email][:to], params[:email][:message]).deliver
  end
  
end