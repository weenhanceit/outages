module Services
  # Class with methods for background handling of events and notifications
  class GenerateNotifications
    # Method to exam outstanding (handeled: false) events and generate required
    # notifications
    def self.call
      # TODO: Review this code and review whether this needs DRYing or
      # improving the performance
      # puts "-xxyeh-: TP_#{__LINE__}"
      # puts "generate_notification #{__LINE__}: - -xxyeh- -"
      # puts "generate_notification.rb #{__LINE__}: -- IN the Loop!!!!!!!!!!!!!!!!!! -xxyeh-"
      events_to_handle = Event.where(handled: false)
      events_to_handle.each do |event|
        # puts "-xxyeh-: TP_#{__LINE__}"
        # puts "generate_notification.rb #{__LINE__}: Event: #{event.id} -xxyeh-"
        # puts "-xxyeh-: #{event.inspect}"
        create_notifications_for_event(event)
      end
    end

    def self.create_notifications_for_event(event)
      if event.outage
        # puts "-xxyeh-: TP_#{__LINE__}"
        # puts "generate_notification.rb #{__LINE__}: Outage: #{event.outage.name} -xxyeh-"
        event.outage.watches.each do |watch|
          # puts "-xxyeh-: TP_#{__LINE__}"
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
      # puts "-xxyeh-: TP_#{__LINE__}"
      event
    end

    def self.create_event_and_notifications(outage, event_type, event_text)
      event = outage.events.create(event_type: event_type,
                                   text: event_text,
                                   handled: true)
      create_notifications_for_event(event)
    end

    # TODO: Write unit tests on this method.
    # If we refactor other tests out of existence, there will be much more
    # risk that we would break this in the future.
    def self.create_reminder(user, outage)
      # rubocop:disable Lint/AssignmentInCondition
      return unless event = create_unique_reminder_event(user, outage)
      # puts "Event created: #{event.inspect}"
      return unless watch = Watch.unique_watch_for(user, outage)
      # puts "Watch found: #{watch.inspect}"
      # rubocop:enable Lint/AssignmentInCondition
      create_notifications(event, watch)
    end

    private

    def self.create_unique_reminder_event(_user, outage)
      outage.events.create(event_type: "reminder",
                           text:
                            "Outaged Scheduled to Begin at " \
                            "#{outage.start_time.to_s(:iso8601)}",
                           handled: true)
    end

    def self.handle_watch(event, watch)
      # puts "-xxyeh-: generate_notification.rb #{__LINE__}:"
      case event.event_type
      when "outage"
        # puts "TP_#{__LINE__} #{watch.user.notify_me_on_outage_changes}"

        # puts "-xxyeh-: generate_notification.rb #{__LINE__}: Notify Me!: #{watch.user.notify_me_on_outage_changes}"
        create_notification(event, watch, "online") if watch.user.notify_me_on_outage_changes
      when "completed"
        # puts "TP_#{__LINE__} #{watch.user.notify_me_on_outage_changes}"

        # puts "-xxyeh-: generate_notification.rb #{__LINE__}: Notify Me!: #{watch.user.notify_me_on_outage_changes}"
        create_notification(event, watch, "online") if watch.user.notify_me_on_outage_complete
      when "overdue"
        # puts "generate_notifications.rb TP_#{__LINE__}: "
        if watch.user.notify_me_on_overdue_outage && !event.outage.completed
          create_notification(event, watch, "online")
          # puts "generate_notifications.rb TP_#{__LINE__}: "
        end
      when "reminder"
        create_notification(event, watch, "online") if watch.user.notify_me_before_outage
      else
        puts "-xxyeh-: WTF! #{event.event_type}"
      end
    end

    def self.create_notification(event, watch, notification_type)
      if Notification.all
                     .where(event: event, notification_type: notification_type)
                     .size.zero?

        Notification.create(watch: watch,
                            event: event,
                            notification_type: notification_type,
                            notified: false)
      end
    end

    def self.create_notifications(event, watch)
      create_notification(event, watch, "online")
      create_notification(event, watch, "email") if watch.user.preference_notify_me_by_email
    end
  end
end
