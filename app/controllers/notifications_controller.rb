class NotificationsController < ApplicationController
  def update
    @notification = current_user.notifications.find(params[:id])
    unless @notification.update(notitication_params)
      logger.error "Notification update failed: " \
        "#{@notification.errors.full_messages}"
      head :internal_server_error
      return
    end
  end

  private

  def notitication_params
    params.require(:notification).permit(:notified)
  end
end
