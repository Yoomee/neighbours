class TagsController < ApplicationController
  include YmTags::TagsController
  expose(:posts) {Post.tagged_with(current_tag.name).page(params[:page])}
end