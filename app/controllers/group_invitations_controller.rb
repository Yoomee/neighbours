class GroupInvitationsController < ApplicationController

  include ActionView::Helpers::TextHelper

  load_and_authorize_resource
  load_resource :group

  def create
    attributes = params[:group].slice(:invitation_emails).merge(:inviter_id => current_user.id)
    if @group.update_attributes(attributes)
      flash[:notice] = "#{pluralize(@group.invitation_emails.split(',').count, 'invitation')} sent"
      redirect_to members_group_path(@group)
    else
      render :action => 'new'
    end
  end

  def new
  end

  def show
    if allowed_to_view?(@group_invitation)
      @group = @group_invitation.group
      render :template => 'groups/show'
    else
      raise CanCan::AccessDenied
    end
  end

  private
  def allowed_to_view?(invitation)
    invitation.ref == params[:ref] || signed_in?(invitation.user)
  end

end