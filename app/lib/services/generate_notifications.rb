module Services
  # Class with methods for background handling of events and notifications
  class GenerateNotifications
    # Method to exam outstanding (handeled: false) events and generate required
    # notifications
    def self.call
      # TODO: Review this code and review whether this needs DRYing or
      # improving the performance
      events_to_handle = Event.where(handled: false)
      events_to_handle.each do |event|
        create_notifications_for_event(event)
      end
    end

    # Creates an event, and then all notifications for the event
    # Used for :outage and :completed events
    # These events generate notifications for all users watching the event
    def self.create_event_and_notifications(outage, event_type, event_text)
      event = outage.events.create(event_type: event_type,
                                   text: event_text,
                                   handled: true)
      event.reload
      create_notifications_for_event(event)
    end

    # Enumerates a set of watches for the event outage and creates required
    # notifications.
    # Note the watch set will contain 1 or 0 watches for any user
    def self.create_notifications_for_event(event)
      if event.outage
        event.outage.watches_unique_by_user.each do |watch|
          # puts "Gen_notifications #{__LINE__}: Watch: #{watch.inspect}"
          create_required_notifications event, watch
        end
      end
      event
    end

    ##
    # Create an overdue event and all notifications for it.
    def self.create_overdue(user, outage)
      # rubocop:disable Lint/AssignmentInCondition
      return unless event = create_unique_overdue_event(user, outage)
      # puts "Event created: #{event.inspect}"
      return unless watch = Watch.unique_watch_for(user, outage)
      # puts "Watch found: #{watch.inspect}"
      # rubocop:enable Lint/AssignmentInCondition
      create_notifications(event, watch)
    end

    ##
    # Create an overdue event and all notifications for it.
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

    def self.create_unique_overdue_event(_user, outage)
      outage.events.create(event_type: "overdue",
                           text: "Outage Not Completed As Scheduled",
                           handled: true)
    end

    def self.create_unique_reminder_event(_user, outage)
      outage.events.create(event_type: "reminder",
                           text: "Outaged Scheduled to Begin at " \
                           "#{outage.start_time.to_s(:iso8601)}",
                           handled: true)
    end

    # Generates required notifications for :outage and :completed events
    # for a specific watch
    def self.create_required_notifications(event, watch)
      # puts "-xxyeh-: generate_notification.rb #{__LINE__}:"
      case event.event_type
      when "outage"
        # puts "TP_#{__LINE__} #{watch.user.notify_me_on_outage_changes}"

        # puts "-xxyeh-: generate_notification.rb #{__LINE__}: Notify Me!: #{watch.user.notify_me_on_outage_changes}"
        # create_notification(event, watch, "online") if watch.user.notify_me_on_outage_changes
        create_notifications(event, watch) if watch.user.notify_me_on_outage_changes
      when "completed"
        # puts "TP_#{__LINE__} #{watch.user.notify_me_on_outage_changes}"

        # puts "-xxyeh-: generate_notification.rb #{__LINE__}: Notify Me!: #{watch.user.notify_me_on_outage_changes}"
        # create_notification(event, watch, "online") if watch.user.notify_me_on_outage_complete
        create_notifications(event, watch) if watch.user.notify_me_on_outage_complete
      when "overdue"
        # puts "generate_notifications.rb TP_#{__LINE__}: "
        if watch.user.notify_me_on_overdue_outage && !event.outage.completed
          create_notification(event, watch, "online")
          # puts "generate_notifications.rb TP_#{__LINE__}: "
        end
      when "reminder"
        create_notification(event, watch, "online") if watch.user.notify_me_before_outage
      when "outage_note"
        # puts "#{__FILE__} Line #{__LINE__}: ---"
        create_notifications(event, watch) if watch.user.notify_me_on_note_changes
      else
        puts "-xxyeh-: WTF! #{event.event_type}"
      end
    end

    def self.create_notification(event, watch, notification_type)
      # TODO: the following search may not be quite right
      if Notification.all
                     .where(event: event,
                            watch: watch,
                            notification_type: notification_type)
                     .size.zero?
        # puts "#{__FILE__} Line #{__LINE__}: ---#{event.outage.name}"
        Notification.create(watch: watch,
                            event: event,
                            notification_type: notification_type,
                            notified: false)
      end
    end

    def self.create_notifications(event, watch)
      # puts "#{__FILE__} Line #{__LINE__}: ---"
      create_notification(event, watch, "online")
      create_notification(event, watch, "email") if watch.user.preference_notify_me_by_email
      # TODO: And trigger the e-mail here if the user wants immediate e-mails.
      if watch.user.preference_individual_email_notifications
        email = NotificationMailer.notification_email(watch.user)
        email.deliver_now
        # puts " ---- #{__LINE__}:  #{ActionMailer::Base.deliveries.inspect}"
      end
    end
  end
end
