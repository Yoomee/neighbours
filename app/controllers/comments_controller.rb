class CommentsController < ApplicationController
  include YmPosts::CommentsController
  load_and_authorize_resource
  
  def create
    @comment = current_user.comments.create(params[:comment])
    UserMailer.new_comment(@comment).deliver
  end
  
end