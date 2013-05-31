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
    end
  end

  def show
    @posts = @group.posts.page(params[:page])
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