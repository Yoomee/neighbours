class PostsController < ApplicationController
  include YmPosts::PostsController
  load_and_authorize_resource

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      UserMailer.new_group_post(@post).deliver if @post.target.is_a?(Group)
      @new_post = Post.new(:target => @post.target, :user => @post.user)
    end
  end
  
  def index
    @neighbourhood = params[:neighbourhood] ? Neighbourhood.first : nil
    @posts = @neighbourhood ? @neighbourhood.posts.order("created_at DESC").page(params[:page]) : Post.order("created_at DESC").page(params[:page])
  end
  
end