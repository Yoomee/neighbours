class GroupInvitationsController < ApplicationController

  include ActionView::Helpers::TextHelper

  load_resource :group, :except => 'show'
  load_and_authorize_resource :through => :group, :through_association => :invitations, :except => 'show'
  load_and_authorize_resource :group_invitation, :only => 'show'

  def create
    @group.invitations(true) # removes blank invitation built by cancan, which brakes group validation
    attributes = params[:group].slice(:invitation_emails_s).merge(:inviter_id => current_user.id)
    if @group.update_attributes(attributes)
      flash[:notice] = "#{pluralize(@group.invitation_emails.count, 'invitation')} sent"
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