class NotesController < ApplicationController
  def create
    # puts "PARAMS: #{params.inspect}"
    # NOTE: How will this work when we have notes on CIs?
    @outage = current_account.outages.find(params[:outage_id])
    if !@outage.notes.create(notes_params.merge(user: current_user))
      # puts "NOTE SAVE FAILED"
      logger.warn @outage.errors.full_messages
    end

    redirect_to outage_path(@outage)
  end

  def destroy
    puts "DESTROY PARAMS: #{params.inspect}"
    @note = current_user.notes.find(params[:id])
    if @note.destroy
      puts "ABOUT TO RESPOND..."
      respond_to do |format|
        puts "...WITH JAVASCRIPT"
        format.js
      end
    else
      puts "DESTROY FAILED #{@note.errors.full_messages}"
      logger.warn @note.errors.full_messages
    end
  end

  private

  def notes_params
    # puts "PERMITTED: #{params.require(:note).permit(:note).inspect}"
    params.require(:note).permit(:note)
  end
end
