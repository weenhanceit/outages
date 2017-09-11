class NotesController < ApplicationController
  def create
    # puts "CREATE PARAMS: #{params.inspect}"
    @notable = if params[:outage_id].present?
      current_account.outages.find(params[:outage_id])
    else
      current_account.cis.find(params[:ci_id])
    end
    @note = @notable.notes.build(notes_params.merge(user: current_user))
    if Services::SaveNote.call(@note)
      respond_to do |format|
        format.js
      end
    else
      logger.warn @notable.errors.full_messages
      respond_to do |format|
        format.js do
          render "edit"
        end
      end
    end
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    # puts "nc #{__LINE__}: DESTROY !!!! #{@note.note}"
    if Services::SaveNote.destroy(@note)
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
    @note.assign_attributes(notes_params)
    if Services::SaveNote.call(@note)
      respond_to do |format|
        format.js
      end
    else
      logger.warn @note.errors.full_messages
    end
  end

  private

  def notes_params
    # puts "PERMITTED: #{params.require(:note).permit(:note).inspect}"
    params.require(:note).permit(:note)
  end
end
