class ChampionsController < ApplicationController
  
  def show
    user = User.find_by_id(params[:user_id]) || current_user
    if @champion = user.community_champion      
      @wall_posts = @champion.wall_posts.visible_to(current_user).page(params[:page])
    else
      flash[:error] = "You don't have a neighbourhood champion at the moment"
      redirect_to :root
    end
  end
  
end