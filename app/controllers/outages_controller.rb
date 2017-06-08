class OutagesController < ApplicationController
  def index
    # puts "IN INDEX"
    @outages = current_user.account.outages.where(active: true)
  end

  def show
    # puts "IN SHOW"
    @outage = current_user.account.outages.find_by(id: params[:id])
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults)
  end

  def edit
    # puts "IN EDI"
    @outage = current_user.account.outages.find_by(id: params[:id])
  end

  def create
    @outage = Outage.new(outage_params)
    @outage.account = current_user.account
    if @outage.save
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :new
    end
  end

  def update
    @outage = current_user.account.outages.find_by(id: params[:id])
    if @outage.update(outage_params)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  def destroy
    @outage = current_user.account.outages.find_by(id: params[:id])
    @outage.active = false
    if @outage.save
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  private

  # TODO: Does Rails have a better way to handle model defaults?
  def outage_defaults
    {
      active: true,
      causes_loss_of_service: true,
      completed: false
    }
  end

  def outage_params
    params.require(:outage).permit(:id,
      :account_id,
      :active,
      :causes_loss_of_service,
      :completed,
      :description,
      :end_time,
      :name,
      :start_time)
  end
end
