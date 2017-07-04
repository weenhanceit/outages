class OutagesController < ApplicationController
  before_action :outage, only: [
    :update, :edit, :show, :destroy
  ]
  before_action :outages, only: [
    :day, :fourday, :index, :month, :week
  ]

  def index
    # puts "IN INDEX"
  end

  def show
    # puts "IN SHOW"
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults.merge(account: current_account))
  end

  def edit
    #  puts "IN EDIT"
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
    # logger.debug "outages_controller.rb TP_#{__LINE__} Is this an outage? #{@outage.is_a?(Outage)}   #{@outage.inspect}"

    @outage.assign_attributes(outage_params)
    # logger.debug "outages_controller.rb TP_#{__LINE__} changed: #{@outage.changed?}"
    # @outage.attributes= outage_params
    # o = Outage.find(@outage.id)
    # puts "outages_controller.rb TP_#{__LINE__} #{o.inspect}"
    # puts "outages_controller.rb TP_#{__LINE__} #{@outage.inspect} changed: #{@outage.changed?}"
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
  # Must take into account what the default values for the filter fields are
  # going to be.
  # Also implements the rules to keep the right outages on the page, for
  # example, when showing a month view, show the whole month's outages, even
  # if the earliest and latest are only a couple of days apart.
  def outages
    if action_name == "index" && params[:latest].blank?
      params[:latest] = if params[:earliest].blank?
                          helpers.default_latest.to_s(:browser)
                        else
                          helpers.default_latest(Time
                          .zone
                          .parse(params[:earliest]))
                                 .to_s(:browser)
                        end
      puts "SET latest TO #{params[:latest]}"
    end

    puts "PARAMS after reverse merge: #{params.reverse_merge(
      watching: 'Of interest to me',
      earliest: helpers.default_earliest.to_s(:browser)).inspect}"
    @outages = current_user.filter_outages(
      params.reverse_merge(
        watching: "Of interest to me",
        earliest: helpers.default_earliest.to_s(:browser)))
  end

  def update_watches
    @outage.update_watches(current_user, params[:outage][:watched].in?(%w(1 true)))
  end
end
