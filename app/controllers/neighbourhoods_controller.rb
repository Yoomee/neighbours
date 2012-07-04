class NeighbourhoodsController < ApplicationController
  
  def show
    @needs = Need.order("created_at DESC").limit(4)
  end
  
end