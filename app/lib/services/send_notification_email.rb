module Services
  # Class with methods for background handling of events and notifications
  class SendNotificationEmail
    # Method Checks if user has outstanding email notifications and, if so,
    # sends an email to the user including all outstanding notifications
    def self.call(user)
      # puts "sne.rb #{__LINE__}:"
      email = nil
      Notification.transaction do
        notifications = user.outstanding_notifications(:email)
        # puts "sne.rb #{__LINE__}: #{notifications.inspect}"
        if user.preference_notify_me_by_email && !notifications.empty?
          # puts "nm.rb - #{__LINE__}: #{user.email}"
          email = NotificationMailer.notification_email(user)
          email.deliver_now
        end
        notifications.each do |notification|
          # puts "sne.rb #{__LINE__}: #{notification.inspect}"
          # Mark this notification as notified
          notification.notified = true
          notification.save
        end
      end

      email
    end

    ##  ** Deprecated
    #   ** This method would be used to improve information in email
    #   ** notifications - but we have decided to focus on initially
    #   ** providing basic messages without any optimization or
    #   ** enhancements.   TODO: review!
    # Returns a array of hashes, 1 element per notification
    # Hash is {event: event, watches: [watch1, watch2, ...]}
    # All notifications are marked as notified
    # def self.get_email_notifications_list_and_mark_notified(user)
    #   notifications = user.outstanding_notifications("email")
    #   list = notifications.each_with_object([]) do |notification, list|
    #     puts "sne.rb #{__LINE__}: #{notifications.inspect}"
    #     # Mark this notification as notified
    #     notification.notified = true
    #     notification.save
    #
    #     # Determine if we have seen this event
    #     index = list.find_index do |m|
    #       m[:event] == notification.event
    #     end
    #
    #     # Add to our array if a newly unique event, or add to the watches if the
    #     # list already has the event
    #     if index.nil?
    #       list << { event: notification.event,
    #                 watches: [notification.watch] }
    #     else
    #       list[index][:watches] << notification.watch
    #     end
    #     # puts "INSPECT: #{list.inspect}"
    #     list
    #   end
    #   puts "sne.rb #{__LINE__}: INSPECT 2: #{list.inspect}"
    #
    #   list
    # end

  end
end
