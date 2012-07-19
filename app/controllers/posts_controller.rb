class PostsController < ApplicationController
  include YmPosts::PostsController
  load_and_authorize_resource
  
  def index
    @neighbourhood = params[:neighbourhood] ? Neighbourhood.first : nil
    @posts = @neighbourhood ? @neighbourhood.posts.order("created_at DESC").page(params[:page]) : Post.order("created_at DESC").page(params[:page])
  end
  
end