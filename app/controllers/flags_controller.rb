class FlagsController < ApplicationController
  
  load_and_authorize_resource
  
  def create
    @flag.user = current_user
    if @flag.save
      flash[:notice] = "Thank you for flagging this content as inappropriate. We have been notified and will take a look as soon as possible."
      UserMailer.new_flag(@flag).deliver
    else
      flash[:error] = "There was a problem, this content has not been flagged as innapropriate."
    end
    return_or_redirect_to(@flag.resource || root_path)
  end
  
  def index
    @flags = Flag.scoped
  end
  
end