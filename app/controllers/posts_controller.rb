class PostsController < ApplicationController
  include YmPosts::PostsController
  load_and_authorize_resource
end