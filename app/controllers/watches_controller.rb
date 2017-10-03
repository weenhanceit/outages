class WatchesController < ApplicationController
  def create
    # puts "In controller Watch.count: #{Watch.count}"
    @watch = Watch.new(watch_params)
    if !@watch.save
      logger.error("Save failed: #{@watch.errors.full_message} #{@watch.inspect}")
    end

    respond_to do |format|
      format.js do
        # UGH: This trick puts the same label back as the page had.
        @label = params[:label] || ""
        render "edit", locals: { row_index: params[:row_index] }
      end
    end
    # puts "Leaving controller Watch.count: #{Watch.count}"
  end

  def update
    # puts "In controller Watch.count: #{Watch.count}"
    @watch = current_user.watches.unscope(where: :active).find(params[:id])
    if !@watch.update(watch_params)
      logger.error("Save failed: #{@watch.errors.full_message} #{@watch.inspect}")
    end

    respond_to do |format|
      format.js do
        # UGH: This trick puts the same label back as the page had.
        @label = params[:label] || ""
        render "edit", locals: { row_index: params[:row_index] }
      end
    end
    # puts "@watch.active: #{@watch.active}"
    # puts "Leaving controller Watch.count: #{Watch.count}"
  end

  private

  def watch_params
    params.require(:watch).permit(:active,
      :id,
      :user_id,
      :watched_id,
      :watched_type)
  end
end
