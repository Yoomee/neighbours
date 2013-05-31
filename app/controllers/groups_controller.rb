class GroupsController < ApplicationController

  load_and_authorize_resource

  def about
    
  end

  def create
    @group = current_user.groups.build(params[:group])
    if @group.save
      flash_notice(@group)
      redirect_to groups_path
    else
      render :action => 'new'
    end
  end

  def index
    
  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.page(params[:page])
  end

end