class GroupRegistrationsController < ApplicationController

  def new
    @user = User.new(:group_invitation_id => params[:group_invitation_id])
  end

  def create
    @user = User.new(params[:user].merge(:role => 'group_user'))
    if @user.save
      sign_in(@user)
      flash[:notice] = 'Thanks for registering!'
      invitation = GroupInvitation.find_by_id(@user.group_invitation_id)
      if invitation && (!invitation.group.private? || invitation.user_id == @user.id)
        redirect_to join_group_path(invitation.group)
      else
        return_or_redirect_to root_path
      end
    else
      render :action => 'new'
    end
  end

end