class OutagesController < ApplicationController
  before_action :outage, only: [
    :update, :edit, :show, :destroy
  ]
  before_action :outages, only: [
    :day, :fourday, :index, :month, :week
  ]

  def index
    # puts "IN INDEX"
    @online_notifications = current_user.outstanding_online_notifications
  end

  def show
    # puts "IN SHOW"
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults.merge(account: current_account))
  end

  def edit
    # puts "IN EDIT"
    @outage.watched_by(current_user)
  end

  def create
    # puts "IN CREATE"
    @outage = Outage.new(outage_params)
    @outage.account = current_user.account
    update_watches
    if Services::SaveOutage.call(@outage)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :new
    end
  end

  def update
    # puts "IN UPDATE"
    update_watches
    # puts "params.require(:outage): #{params.require(:outage).inspect}"
    # puts "outage_params: #{outage_params.inspect}"
    @outage.update_attributes(outage_params)
    if Services::SaveOutage.call(@outage)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  def destroy
    # puts "IN DESTROY"
    @outage.active = false
    if Services::SaveOutage.call(@outage)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  private

  ##
  # Set up the @outage instance variable for the single-instance actions.
  def outage
    @outage = current_user
              .account
              .outages
              .includes(:watches, :cis_outages, :cis)
              .find(params[:id])

              #  puts "!!#{__LINE__}: Outage loaded: watches.size: #{@outage.watches.size} cis.size: #{@outage.cis.size} cis_outages.size: #{@outage.cis_outages.size}"
  end

  # Some sources say the best way to do model defaults is in an
  # `after_initialize` callback. The approach below works as a way of
  # defaulting in the UI, but not making any preconceived notions about
  # the model itself.
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
      :start_time,
      cis_outages_attributes: [:id, :ci_id, :outage_id, :_destroy],
      available_cis_attributes: [:ci_id, :_destroy])
  end

  ##
  # Set up the @outages instance variable for the "index-like" actions.
  def outages
    @outages = current_user.account.outages.where(active: true)
  end

  def update_watches
    @outage.update_watches(current_user, params[:outage][:watched].in?(["1", "true"]))
  end
end
