class SearchesController < ApplicationController
  include YmSearch::SearchesController
  
  def index
    @search_queries = SearchQuery.order("created_at DESC")
  end
  
end