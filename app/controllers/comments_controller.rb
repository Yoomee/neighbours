class CommentsController < ApplicationController
  include YmPosts::CommentsController
  load_and_authorize_resource
end