class CommentsController < ApplicationController
  include YmPosts::CommentsController
  load_and_authorize_resource
  
  def create
    @comment = current_user.comments.create(params[:comment])
    if @comment.post.target && (@comment.post.target.is_a?(Need)|| @comment.post.target.is_a?(Group))
      @comment.email_users
    end
  end
  
end