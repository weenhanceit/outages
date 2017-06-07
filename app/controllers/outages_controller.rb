class OutagesController < ApplicationController
  def index
    # puts "IN INDEX"
    @outages = current_user.account.outages.where(active: true)
  end

  def show
    # puts "IN SHOW"
    @outage = current_user.account.outages.find_by(active: true, id: params[:id])
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new
    puts "WTF" unless @outage
  end

  def edit
    # puts "IN EDI"
    @outage = current_user.account.outages.find_by(active: true, id: params[:id])
  end

  def create
  end

  def update
  end

  def destroy
  end
end
