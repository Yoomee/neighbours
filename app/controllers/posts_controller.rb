class PostsController < ApplicationController
  include YmPosts::PostsController
  load_and_authorize_resource

  def create
    @post = current_user.posts.build(params[:post])
    if @post.target_type == 'Need'
      @need = Need.find(@post.target_id)
      @offers = @need.offers
    elsif @post.target_type == 'GeneralOffer'
      @general_offer = GeneralOffer.find(@post.target_id)
    end
    @post.user = current_user
    if @post.save
      if (@post.target_type == 'Group') && (@post.user != @post.target.owner)
        @post.target.members.without(@post.user).each do |member|
          UserMailer.delay.new_group_post(@post, member)
        end
      elsif(@post.target_type == 'Neighbourhood')
        members = User.where(:is_community_champion => true)
        members.without(@post.user).each do |member|
          UserMailer.delay.new_forum_post(@post, member)
        end
      end
      if @post.context == 'chat'
        @new_post = Post.new(:target => @post.target, :user => @post.user, :context => 'chat')
        if @post.target_type == 'Need'
          UserMailer.new_need_chat(@post).deliver
        elsif @post.target_type == 'GeneralOffer'
          UserMailer.new_general_offer_chat(@post).deliver
        end
      else
        @new_post = Post.new(:target => @post.target, :user => @post.user)
      end
    end
  end
  
  def index
    @neighbourhood = params[:neighbourhood] ? Neighbourhood.first : nil
    @posts = @neighbourhood ? @neighbourhood.posts.order("created_at DESC").page(params[:page]) : Post.order("created_at DESC").page(params[:page])
  end
  
end