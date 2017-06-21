module Services
  # Class with methods for background handling of events and notifications
  class GenerateNotifications
    # Method to exam outstanding (handeled: false) events and generate required
    # notifications
    def self.call
      # Rails.logger.debug " - xde -"
      # puts "generate_notification #{__LINE__}: - xde -"
      # Rails.logger.debug "generate_notification.rb #{__LINE__}: -- IN the Loop!!!!!!!!!!!!!!!!!! xde"
      events_to_handle = Event.where(handled: false)
      events_to_handle.each do |event|
        # puts "TP_#{__LINE__}"
        # Rails.logger.debug "generate_notification.rb #{__LINE__}: Event: #{event.id} xde"
        # Rails.logger.debug "xde: #{event.inspect}"
        if event.outage
          # puts "TP_#{__LINE__}"
          # Rails.logger.debug "generate_notification.rb #{__LINE__}: Outage: #{event.outage.name} xde"
          event.outage.watches.each do |watch|
            # puts "TP_#{__LINE__}"
            handle_watch event, watch
          end
          event.outage.cis.map(&:watches).flatten.each do |watch|
            # puts "TP_#{__LINE__}"
            handle_watch event, watch
          end

          event.outage.cis.map(&:ancestors_affected)
               .flatten.map(&:watches).flatten.each do |watch|
            # puts "TP_#{__LINE__}"
            handle_watch event, watch
          end
        end
        event.handled = true
        event.save
      end
    end

    private

    def self.handle_watch(event, watch)
      case event.event_type
      when "outage"
        # puts "TP_#{__LINE__} #{watch.user.notify_me_on_outage_changes}"

        # Rails.logger.debug "xde: generate_notification.rb #{__LINE__}: Notify Me!: #{watch.user.notify_me_on_outage_changes}"
        create_notification(event, watch, "online") if watch.user.notify_me_on_outage_changes
      else
        Rails.logger.debug "xde: WTF! #{event.event_type}"
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
