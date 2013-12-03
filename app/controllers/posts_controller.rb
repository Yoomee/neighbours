class PostsController < ApplicationController
  include YmPosts::PostsController
  load_and_authorize_resource

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      if (@post.target_type == 'Group') && (@post.user != @post.target.owner)
        @post.target.members.without(@post.user).each do |member|
          UserMailer.delay.new_group_post(@post, member)
        end
      end
      @new_post = Post.new(:target => @post.target, :user => @post.user)
    end
  end
  
  def index
    @neighbourhood = params[:neighbourhood] ? Neighbourhood.first : nil
    @posts = @neighbourhood ? @neighbourhood.posts.order("created_at DESC").page(params[:page]) : Post.order("created_at DESC").page(params[:page])
  end
  
end