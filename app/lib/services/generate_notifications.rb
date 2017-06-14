module Services
  # Class with methods for background handling of events and notifications
  class GenerateNotifications
    # Method to exam outstanding (handeled: false) events and generate required
    # notifications
    def self.call
      events_to_handle = Event.where(handled: false)
      events_to_handle.each do |event|
        event.outage.watches.each do |watch|
          handle_watch event, watch
        end
        event.outage.cis.map(&:watches).flatten.each do |watch|
          handle_watch event, watch
        end

        event.outage.cis.map(&:ancestors_affected)
          .flatten.map(&:watches).flatten.each do |watch|

          handle_watch event, watch
        end
      end
    end

    private

    def self.handle_watch(event, watch)
      case event.event_type
      when "outage"
        create_notification(event, watch, "online") if watch.user.notify_me_on_outage_changes
      else
        puts "WTF!"
      end
    end

    def self.create_notification(event, watch, notification_type)
      Notification.create(watch: watch,
        event: event,
        notification_type: notification_type,
        notified: false)
    end
  end
end
