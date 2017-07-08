class NotesController < ApplicationController
  def create
    puts "PARAMS: #{params.inspect}"
    # NOTE: How will this work when we have notes on CIs?
    @outage = current_account.outages.find(params[:outage_id])
    if !@outage.notes.create(notes_params.merge(user: current_user))
      puts "NOTE SAVE FAILED"
      logger.warn @outage.errors.full_messages
    end

    redirect_to outage_path(@outage)
  end

  private

  def notes_params
    puts "PERMITTED: #{params.require(:note).permit(:note).inspect}"
    params.require(:note).permit(:note)
  end
end
