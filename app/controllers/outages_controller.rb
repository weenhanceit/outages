class OutagesController < ApplicationController
  def index
    # puts "IN INDEX"
    @outages = current_user.account.outages.where(active: true)
  end

  def show
    # puts "IN SHOW"
    load_outage
  end

  def new
    # puts "IN NEW"
    @outage = Outage.new(outage_defaults)
  end

  def edit
    # puts "IN EDI"
    load_outage
  end

  def create
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
    load_outage
    update_watches
    if @outage.update(outage_params)
      redirect_to outages_path
    else
      logger.warn @outage.errors.full_messages
      render :edit
    end
  end

  def destroy
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

  def load_outage
    @outage = current_user.
                account.
                outages.
                includes(:watches).
                find(params[:id])
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
      :start_time)
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
