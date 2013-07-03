class GroupRegistrationsController < ApplicationController

  skip_before_filter :clear_pre_register_user_id

  def new
    @user = User.find_by_id(session[:pre_register_user_id]) || User.new(:group_invitation_id => params[:group_invitation_id])
    @user.last_name = nil if @user.last_name == '_BLANK_'
  end

  def create
    debugger
    if @user = User.find_by_id(session[:pre_register_user_id])
      @user.attributes = (params[:user]).merge(:role => 'group_user')
    else
      @user = User.new(params[:user].merge(:role => 'group_user'))
    end
    if @user.in_group_and_user_creation?
      @user.owned_groups.each {|g| g.owner = @user}
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
          if @user.errors[:email] == ["is already taken.  <a href='/login'>Log in</a> if this is your account"] && User.find_by_email(@user.email).role == 'pre_registration'
            @already_pre_registered = true
            UserMailer.complete_group_registration(User.find_by_email(@user.email)).deliver
          end
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
        if @user.errors[:email] == ["is already taken.  <a href='/login'>Log in</a> if this is your account"] && User.find_by_email(@user.email).role == 'pre_registration'
          @already_pre_registered = true
          UserMailer.complete_group_registration(User.find_by_email(@user.email)).deliver
        end
        render :action => 'new'
      end
    end
  end

end