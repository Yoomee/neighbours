class GroupRegistrationsController < ApplicationController

  def new
    @user = User.new(:group_invitation_id => params[:group_invitation_id])
  end

  def create
    @user = User.new(params[:user].merge(:role => 'group_user'))
    @user.owned_groups.each {|g| g.owner = @user}
    if @user.in_group_and_user_creation?
      if @user.current_group_step_group?
        @user.owned_groups.each {|g| g.owner = @user}
        if @user.owned_groups.first.valid?
          @user.current_group_step = 'you'
        end
        render :template => 'groups/new'
      elsif @user.current_group_step_you?
        if params[:back]
          @user.current_group_step = 'group'
          render :template => 'groups/new'
        elsif @user.save
          sign_in(@user)
          flash[:notice] = 'Thanks for registering!'
          invitation = GroupInvitation.find_by_id(@user.group_invitation_id)
          if invitation && (!invitation.group.private? || invitation.user_id == @user.id)
            redirect_to join_group_path(invitation.group)
          else
            return_or_redirect_to groups_path
          end
        else
          render :template => 'groups/new'
        end
      else
        render :template => 'groups/new'
      end
    else
      if @user.save
        sign_in(@user)
        flash[:notice] = 'Thanks for registering!'
        invitation = GroupInvitation.find_by_id(@user.group_invitation_id)
        if invitation && (!invitation.group.private? || invitation.user_id == @user.id)
          redirect_to join_group_path(invitation.group)
        else
          return_or_redirect_to groups_path
        end
      else
        render :action => 'new'
      end
    end
  end

end