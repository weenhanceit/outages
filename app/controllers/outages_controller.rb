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
    # TODO: Remove the next line. Test it, of course.
    @available_cis = all_cis
  end

  def edit
    # puts "IN EDIT"
    load_outage
    # TODO: Remove the next line. Test it, of course.
    @available_cis = all_cis - @outage.cis
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
      :start_time,
      cis_outages_attributes: [:id, :ci_id, :outage_id, :_destroy],
      available_cis_attributes: [:ci_id, :_destroy])
  end

  def update_watches
    # puts "update_watches wants to #{params[:outage][:watched] == '1' ? 'Add' : 'Delete'} a watch."
    # puts "update_watches watches.size before: #{@outage.watches.size}"
    # puts "OutageController params: #{params.inspect}"
    #
    # puts "current_user.id: #{current_user.id}"
    # puts "Watch.where(user_id: current_user.id).last.inspect: #{Watch.where(user_id: current_user.id).last.inspect}"
    #
    watch = @outage.watches.where(user_id: current_user.id).first

    # puts "What the hell is watch? #{watch.inspect}"
    #
    if params[:outage][:watched] == "0"
      # puts "Remove watch" if watch
      @outage.watches.destroy(watch) if watch
    elsif !watch
      # The usual Rails dance: set both sides of the association so the
      # autosave will work.
      watch = @outage.watches.build(user_id: current_user.id)
      watch.watched = @outage
      # puts "Set watch, watches: #{@outage.watches.inspect}"
    end
    # puts "update_watches watches.size after: #{@outage.watches.size}"
  end
end
