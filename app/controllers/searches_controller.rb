class SearchesController < ApplicationController
  def index
    @search_criteria = params["criteria"]
    @results = PgSearch::Extensions.multisearch(current_account, @search_criteria)
  end
end
