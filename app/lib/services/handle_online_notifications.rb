module Services
  # Class with methods for retrieving and marking online notifications
  # as notified
  class HandleOnlineNotifications
    # Method retrieve outstanding notifications for a user
    def self.call
      # TODO: the following should be run as a 'background task'  For demo
      # purposes, this is run whenever this method is called (usually from
      # a controller index method)

      # Services::GenerateNotifications.call

      # notification_list = []
      # user.notifications.where(notified: false, notification_type: "online").each do |notification|
      #   # TODO: review what this method should return. One alternative is to
      #   # return the notification and allow other methods to determine the info
      #   # of interest.  Returning an array allows for future algorithms to
      #   # optimize the number of notifications to be added to this method.
      #   notification_list << { outage_id: notification.event.outage.id,
      #     outage_name: notification.event.outage.name,
      #     event_type: event_info,
      #     event: notification.event.text,
      #     reason: reason,
      #     event_time: notification.event.created_at}
      # end
      # puts " ------ notification_list ---- #{notification_list.size}"
      # notification_list
    end
  end
end
