class StatsController < ApplicationController
  def index
    @neighbourhoods = Neighbourhood.all
  end
end