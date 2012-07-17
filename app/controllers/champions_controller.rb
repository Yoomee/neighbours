class ChampionsController < ApplicationController
  
  def show
    if current_user && current_user.community_champion
      @champion = current_user.community_champion
      @wall_posts = @champion.wall_posts.visible_to(current_user).page(params[:page])
    else current_user
      flash[:error] = "You don't have a community champion at the moment"
      redirect_to :root
    end
  end
  
end