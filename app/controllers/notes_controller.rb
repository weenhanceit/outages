class NotesController < ApplicationController
  def create
    # puts "PARAMS: #{params.inspect}"
    # NOTE: How will this work when we have notes on CIs?
    # TODO: Make this ajaxy.
    @outage = current_account.outages.find(params[:outage_id])
    unless @outage.notes.create(notes_params.merge(user: current_user))
      # puts "NOTE SAVE FAILED"
      logger.warn @outage.errors.full_messages
    end

    redirect_to outage_path(@outage)
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    if @note.destroy
      respond_to do |format|
        format.js
      end
    else
      logger.warn @note.errors.full_messages
    end
  end

  def edit
    @note = current_user.notes.find(params[:id])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    # puts "UPDATE PARAMS: #{params.inspect}"
    # TODO: Make this ajaxy.
    @note = current_user.notes.find(params[:id])
    unless @note.update(notes_params)
      logger.warn @note.errors.full_messages
    end

    redirect_to outage_path(@note.notable)
  end

  private

  def notes_params
    # puts "PERMITTED: #{params.require(:note).permit(:note).inspect}"
    params.require(:note).permit(:note)
  end
end
