class Notifier
  def event_handler(event)
    subscribed_users = User.find(event.event_type)

    subscribed_users.each do |user|
      if user.interested?(event)
        user.desired_notifications.each do |wanted|
          notification = Notification.new
          notification.save
        end
      end
    end
  end

  EventHandler.subscribe(:event_handler)
end
