class EventSubscriber
  def on_outage_changed(event_details)

  end

  def main
    Event.pending_events.each do |event|

      subscribed_users = User.find(event.event_type)

      subscribed_users.each do |user|
        if user.interested?(event)
          user.desired_notifications.each do |wanted|
            notification = Notification.new
            notification.save
          end
        end
      end

      event.pending = false
      event.save
    end
  end
end


class EventSubscriber
  def main
    Event.pending_events.each do |event|

      subscribed_users = User.find_by_event_type(event.event_type)

      subscribed_users.each do |user|
        if user.interested?(event.outage_id)
          user.desired_notifications.each do |wanted|
            notification = Notification.new(event.event_text)
            notification.save
          end
        end
      end

      event.pending = false
      event.save
    end
  end
end







class EventHandler
  def subscribe(handler)
    @handler << handler
  end

  def main
    Event.pending_events.each do |event|
      @handler.each |handler| do
        if (handler.call(event))
          event.pending = false
          event.save
        end
      end
    end
  end
end
