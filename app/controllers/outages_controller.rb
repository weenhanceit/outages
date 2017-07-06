class OutagesController < ApplicationController
  layout "application", except: [:day, :fourday, :index, :month, :week]

  before_action :outage, only: [
    :update, :edit, :show, :destroy
  ]

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

  def day
    # puts "DAY PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.to_date.to_s(:browser)
    params[:latest] = (start_date + 1.day).to_date.to_s(:browser)
    params[:start_date] = start_date.to_s(:ymd)
    outages
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

  def edit
    #  puts "IN EDIT"
    @outage.watched_by(current_user)
  end

  def fourday
    # puts "FOURDAY PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.to_date.to_s(:browser)
    params[:latest] = (start_date + 4.days).to_date.to_s(:browser)
    params[:start_date] = start_date.to_s(:ymd)
    outages
  end

  def index
    # puts "INDEX PARAMS: #{params.inspect}"
    start_date = normalize_params

    if params[:earliest].blank? && params[:latest].blank?
      params[:earliest] = session[:earliest] ||
                          helpers.default_earliest.to_s(:browser)
    end

    if params[:latest].blank?
      params[:latest] = helpers.default_latest(Time
      .zone
      .parse(params[:earliest]))
                               .to_s(:browser)
      # puts "SET latest TO #{params[:latest]}"
    end

    params[:start_date] = start_date.to_s(:ymd)
    outages
  end

  def month
    # puts "MONTH PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date
                        .beginning_of_month
                        .beginning_of_week
                        .to_s(:browser)
    params[:latest] = start_date
                      .end_of_month
                      .end_of_week
                      .to_s(:browser)
    params[:start_date] = start_date.to_s(:ymd)
    outages
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults.merge(account: current_account))
  end

  def show
    # puts "IN SHOW"
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

  def week
    # puts "WEEK PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.beginning_of_week.to_date.to_s(:browser)
    params[:latest] = (start_date.end_of_week + 1.day).to_date.to_s(:browser)
    params[:start_date] = start_date.to_s(:ymd)
    outages
  end

  private

  def normalize_params
    session[:frag] = params[:frag] if params[:frag].present?
    session[:watching] = params[:watching] if params[:watching].present?
    normalize_start_date # Has to be the last line in the method.
  end

  def normalize_start_date
    start_date ||= if params[:start_date].present?
                     #  puts "Set from start_date param"
                     Time.zone.parse(params[:start_date])
                   elsif params[:earliest].present?
                     #  puts "Set from earliest param"
                     Time.zone.parse(params[:earliest])
                   elsif session[:earliest].present?
                     #  puts "Set from session"
                     Time.zone.parse(session[:earliest])
                   else
                     #  puts "Set from default"
                     params[:start_date] = helpers.default_earliest
                   end

    session[:earliest] = start_date.to_s(:browser)
    # puts "Set session to #{session[:earliest]}"

    # puts "start_date: #{start_date}"
    start_date
  end

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
  # NOTE: This implementation is evolving.
  def outages
    # puts "PARAMS before reverse merge: #{params.inspect}"
    # puts "PARAMS after reverse merge: #{params.reverse_merge(
    #   watching: session.fetch(:watching, 'Of interest to me'),
    #   frag: session[:frag],
    #   earliest: helpers.default_earliest.to_s(:browser)).inspect}"
    @outages = current_user.filter_outages(
      params.reverse_merge(
        watching: session.fetch(:watching, "Of interest to me"),
        frag: session[:frag],
        earliest: helpers.default_earliest.to_s(:browser)))
  end

  def update_watches
    @outage.update_watches(current_user, params[:outage][:watched].in?(%w(1 true)))
  end
end
