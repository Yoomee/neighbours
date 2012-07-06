class NeighbourhoodsController < ApplicationController
  
  def show
    @helped = Need.resolved.limit(4)
    @need_help = Need.unresolved.limit(4)
  end
  
end