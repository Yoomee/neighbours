class FlagsController < ApplicationController
  
  load_and_authorize_resource
  
  def create
    @flag.user = current_user
    if @flag.save
      flash[:notice] = "Thank you for flagging this content as inappropriate. We have been notified and will take a look as soon as possible."
      UserMailer.new_flag(@flag).deliver
    else
      flash[:error] = "There was a problem, this content has not been flagged as inappropriate."
    end
    return_or_redirect_to(@flag.resource_url || root_path)
  end
  
  def index
    @flags = Flag.unresolved.unremoved_needs.page(params[:page])
  end
  
  def resolve
    @flag.update_attribute(:resolved_at, Time.now)
    redirect_to(flags_path)
  end
  
end