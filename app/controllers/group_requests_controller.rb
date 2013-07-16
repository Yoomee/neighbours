class GroupRequestsController < ApplicationController

  load_resource :only => %w{accept destroy}
  load_resource :group, :only => %w{create index}
  authorize_resource :only => 'create'

  before_filter :check_ability, :only => %w{accept destroy index}

  def accept
    @group.add_member!(@group_request.user, true)
    UserMailer.new_group_member(@group, @group_request.user, :admin_email => true).deliver    
    UserMailer.group_request_accepted(@group_request).deliver
    flash[:notice] = "#{@group_request.user} is now a member of the group"
    redirect_to group_group_requests_path(@group)
  end

  def create
    if @group.has_member?(current_user)
      flash[:notice] = "You're already a member of this group"
    else
      request = @group.requests.find_or_create_by_user_id(current_user.id)
      UserMailer.group_request(request).deliver
      flash[:notice] = "Your request has been sent to the group owner"
    end
    redirect_to @group
  end

  def destroy
    @group_request.destroy
    flash[:notice] = "Join request removed"
    redirect_to group_group_requests_path(@group)
  end

  def index
  end

  private
  def check_ability
    @group ||= @group_request.group
    if @group.owner != current_user && !current_user.try(:admin?)
      raise CanCan::AccessDenied      
    end    
  end

end