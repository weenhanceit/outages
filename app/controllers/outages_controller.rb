class OutagesController < ApplicationController
  include TestSuite
  def index
    @outage_list = outage_list
  end
  def show
    @outage = outage_list[params[:id].to_i]
  end



end
