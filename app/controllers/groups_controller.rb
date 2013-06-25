class GroupsController < ApplicationController

  load_and_authorize_resource

  def create
    @group = current_user.owned_groups.build(params[:group])
    if @group.save
      flash_notice(@group)
      redirect_to @group
    else
      render :action => 'new'
    end
  end

  def delete
    @group.update_attribute(:deleted_at, Time.now)
    flash[:notice] = "Your group has been deleted"
    redirect_to groups_path
  end

  def destroy
    @group.destroy
    flash_notice(@group)
    redirect_to groups_path
  end

  def edit
  end

  def index
    if current_user.nil? || current_user.groups.empty?
      render :action => 'about'
    else
      @groups =  current_user.groups
      @popular_groups = Group.without(@groups).not_private.most_members.paginate(:page => params[:page], :per_page => 8)
    end

  end

  def join
    if @group.add_member!(current_user)
      flash[:notice] = 'You are now a member of this group, welcome!'
      redirect_to @group
    else
      raise CanCan::AccessDenied
    end
  end

  def list
    @groups = Group.order(:name).paginate(:page => params[:page])
  end

  def members
    @members = [@group.owner] + @group.members.without(@group.owner).order('first_name')
  end

  def new
    if current_user
      @group = Group.new
    else
      @user = User.new(:group_invitation_id => params[:group_invitation_id], :in_group_and_user_creation => true)
      @user.owned_groups.build
    end
  end

  def popular
    @popular_groups = Group.not_private.most_members.paginate(:page => params[:page], :per_page => 16)
  end

  def show
  end

  def update
    if @group.update_attributes(params[:group])
      flash_notice(@group)
      redirect_to @group
    else
      render :action => 'edit'
    end
  end

end