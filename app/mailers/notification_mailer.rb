class NotificationMailer < ApplicationMailer
  def notification_email(user)
    # puts "-------- #{__FILE__}:#{__LINE__}  -------"
    @user = user
    @notification_list = get_email_notifications_list(@user)
    @url = "https://outages.weenhanceit.com/users/sign_in"

    Notification.transaction do
      if @user.preference_notify_me_by_email && @notification_list.size > 0
        mail(to: @user.email, subject: "Latest Notifications")
      end
    end
  end

  private

  def get_email_notifications_list(user)
    notifications = user.outstanding_notifications("email")
    list = notifications.each_with_object([]) do |notification, working_list|
      # Mark this notification as notified
      notification.notified = true
      notification.save

      # Determine if we have seen this event
      index = working_list.find_index do |m|
        m[:event] == notification.event
      end

      # Add to our array if a newly unique event, or add to the watches if the
      # list already has the event
      if index.nil?
        working_list << { event: notification.event,
                          watches: [notification.watch] }

      else
        working_list[index][:watches] << notification.watch
      end
      working_list
      puts "INSPECT: #{working_list.inspect}"
    end
    list
  end
end
