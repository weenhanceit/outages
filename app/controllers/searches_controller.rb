class SearchesController < ApplicationController
    include TestSuite
    def index
        @outages = outage_list
        @frag=params["search-criteria"]
    end
end
