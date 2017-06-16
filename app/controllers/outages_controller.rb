class OutagesController < ApplicationController
  def index
    # puts "IN INDEX"
    @outages = current_user.account.outages.where(active: true)
    # @notifications = Services::HandleOnlineNotifications
    #                  .retrieve(current_user).sort_by { |hsh| hsh[:event_time] }
    #                  .reverse
  end

  def show
    # puts "IN SHOW"
    load_outage
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults.merge(account: current_account))
  end

  def edit
    # puts "IN EDIT"
    load_outage
    @outage.watched_by(current_user)
  end

  def create
    # puts "IN CREATE"
    @outage = Outage.new(outage_params)
    @outage.account = current_user.account
    update_watches
    if @outage.save
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :new
    end
  end

  def update
    # puts "IN UPDATE"
    load_outage
    update_watches
    # puts "params.require(:outage): #{params.require(:outage).inspect}"
    # puts "outage_params: #{outage_params.inspect}"
    if @outage.update(outage_params)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  def destroy
    # puts "IN DESTROY"
    load_outage
    @outage.active = false
    if @outage.save
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  private

  def all_cis
    Ci.where(account: current_user.account).order(:name)
  end

  def load_outage
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

  def update_watches
    @outage.update_watches(current_user, params[:outage][:watched].in?(["1", "true"]))
  end
end
