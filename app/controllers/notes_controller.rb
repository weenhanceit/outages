class NotesController < ApplicationController
  def create
    # puts "PARAMS: #{params.inspect}"
    @outage = current_account.outages.find(params[:outage_id])
    @note = @outage.notes.create(notes_params.merge(user: current_user))
    if @note
      respond_to do |format|
        format.js
      end
    else
      # puts "NOTE SAVE FAILED"
      logger.warn @outage.errors.full_messages
      redirect_to outage_path(@outage)
    end
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
    @note = current_user.notes.find(params[:id])
    if @note.update(notes_params)
      respond_to do |format|
        format.js
      end
    else
      logger.warn @note.errors.full_messages
      redirect_to outage_path(@note.notable)
    end
  end

  private

  def notes_params
    # puts "PERMITTED: #{params.require(:note).permit(:note).inspect}"
    params.require(:note).permit(:note)
  end
end
