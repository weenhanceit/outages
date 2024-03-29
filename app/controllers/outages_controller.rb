# frozen_string_literal: true
class OutagesController < ApplicationController
  before_action :outage, only: [
    :edit, :show, :destroy
  ]
  after_action :set_view, only: [
    :day, :fourday, :index, :month, :week
  ]

  def create
    # puts "IN CREATE"
    @outage = Outage.new(outage_params_with_watches)
    @outage.account = current_user.account

    if Services::SaveOutage.call(@outage)
      # puts "Saved outage"
      redirect_to outages_path
    else
      # puts "Failed to save"
      logger.warn "Failed to save outage #{@outage.inspect}, #{@outage.errors.full_messages}"
      online_notifications
      render :new
    end
  end

  def day
    # puts "DAY PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.to_date.to_fs(:browser)
    params[:latest] = start_date.to_date.to_fs(:browser)
    params[:start_date] = start_date.to_fs(:ymd)
    # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"
    outages
    # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"
  end

  def destroy
    # puts "IN DESTROY"
    @outage.active = false
    if Services::SaveOutage.call(@outage)
      redirect_to outages_path
    else
      logger.warn "Failed to save outage #{outage.inspect}, #{@outage.errors.full_messages}"
      online_notifications
      render :edit
    end
  end

  def edit
    #  puts "IN EDIT"
    not_found unless current_user.can_edit_outages?
    # TODO: This hack to make watches work was ugly. Hopefully Ajax can fix.
    @outage.watched_by(current_user)
    # Put in an Array even though there's only one, to trick Rails into generating the right view
    @watched = [@outage.watched_by_or_new(current_user)]
  end

  def fourday
    # puts "FOURDAY PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.to_date.to_fs(:browser)
    params[:latest] = (start_date + 3.days).to_date.to_fs(:browser)
    params[:start_date] = start_date.to_fs(:ymd)
    outages
  end

  def index
    # puts "INDEX PARAMS: #{params.inspect}"
    if params[:view] != "index" &&
       cookies.signed[:default_view] != "index"
      redirect_to action: cookies.signed[:default_view]
    end

    start_date = normalize_params

    if params[:earliest].blank? && params[:latest].blank?
      params[:earliest] = session[:earliest] ||
                          helpers.default_earliest.to_fs(:browser)
    end

    if params[:latest].blank?
      params[:latest] = helpers.default_latest(Time
      .zone
      .parse(params[:earliest]))
                               .to_fs(:browser)
      # puts "SET latest TO #{params[:latest]}"
    end

    params[:start_date] = start_date.to_fs(:ymd)
    outages
  end

  def month
    # puts "MONTH PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date
                        .beginning_of_month
                        .beginning_of_week
                        .to_fs(:browser)
    params[:latest] = start_date
                      .end_of_month
                      .end_of_week
                      .to_fs(:browser)
    params[:start_date] = start_date.to_fs(:ymd)
    outages
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults.merge(account: current_account))
    # Put in an Array even though there's only one, to trick Rails into generating the right view
    @watched = [@outage.watched_by_or_new(current_user)]
  end

  def show
    # puts "IN SHOW"
    @notable = @outage
    @watched = [@outage.watched_by_or_new(current_user)]
    # UGH: This trick is to put a label in the partial way down in the view.
    @label = "Watched"
    session[:sort_order] = params[:sort_order] if params[:sort_order].present?
  end

  def update
    # puts "IN UPDATE"
    # puts params.inspect
    # puts "params.require(:outage): #{params.require(:outage).inspect}"
    # puts "outage_params: #{outage_params.inspect}"
    # logger.debug "outages_controller.rb TP_#{__LINE__} Is this an outage? #{@outage.is_a?(Outage)}   #{@outage.inspect}"

    # puts "@outage.completed before: #{@outage.completed}"
    Watch.unscoped do
      # TODO: Figure out why Rails ignores unscoped in the includes.
      @outage = current_user
                .account
                .outages
                .includes(:cis_outages, :cis) # including watches seems to ignore unscoped
                .find(params[:id])
      @outage.assign_attributes(outage_params_with_watches)
      # puts "@outage.completed after: #{@outage.completed}"
      # logger.debug "outages_controller.rb TP_#{__LINE__} changed: #{@outage.changed?}"
      # @outage.attributes= outage_params
      # o = Outage.find(@outage.id)
      # puts "outages_controller.rb TP_#{__LINE__} #{o.inspect}"
      # puts "outages_controller.rb TP_#{__LINE__} #{@outage.inspect} changed: #{@outage.changed?}"
      if Services::SaveOutage.call(@outage)
        # puts "Saved outage"
        respond_to do |format|
          format.html { redirect_to outages_path }
          format.js { head :ok }
        end
      else
        # puts "Failed to save"
        logger.warn "Failed to save outage #{@outage.inspect}, #{@outage.errors.full_messages}"
        online_notifications
        respond_to do |format|
          format.html { render :edit }
          format.js { head :error }
        end
      end
    end
  end

  def week
    # puts "WEEK PARAMS: #{params.inspect}"
    start_date = normalize_params
    params[:earliest] = start_date.beginning_of_week.to_date.to_fs(:browser)
    params[:latest] = start_date.end_of_week.to_date.to_fs(:browser)
    params[:start_date] = start_date.to_fs(:ymd)
    outages
  end

  private

  def normalize_params
    session[:frag] = params[:frag] unless params[:frag].nil?
    session[:watching] = params[:watching] if params[:watching].present?
    session[:completed] = params[:completed] if params[:completed].present?
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

    session[:earliest] = start_date.to_fs(:browser)
    # puts "Set session to #{session[:earliest]}"

    # puts "start_date: #{start_date}"
    start_date
  end

  ##
  # Set the default view in a cookie.
  def set_view
    cookies.signed[:default_view] = if params[:view].present?
                                      # puts "Setting default view to grid"
                                      params[:view]
                                    else
                                      action_name
                                    end
  end

  ##
  # Set up the @outage instance variable for the single-instance actions.
  # #update has its own, because it has to do this in the unscoped block.
  def outage
    @outage = current_user
              .account
              .outages
              .includes(:watches, :cis_outages, :cis)
              .find(params[:id])
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
      :start_time)
  end

  def outage_params_with_watches
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
      available_cis_attributes: [:ci_id, :_destroy],
      watches_attributes: [
        :id,
        :watched_type,
        :watched_id,
        :user_id,
        :active
      ])
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
    #   completed: session[:completed],
    #   earliest: helpers.default_earliest.to_fs(:browser)).inspect}"
    @outages = current_user.filter_outages(
      params.reverse_merge(
        watching: session.fetch(:watching, "Of interest to me"),
        frag: session[:frag],
        completed: session[:completed],
        earliest: helpers.default_earliest.to_fs(:browser)))
  end
end
