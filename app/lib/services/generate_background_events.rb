module Services
  # Class with methods for background handling of events and notifications
  class GenerateBackgroundEvents
    def self.call
      events = []

      events += check_for_overdue_outages

      events +=  check_for_outage_reminders

      events
    end

    def self.check_for_outage_reminders
      reminder_events = []
      outages = Outage.where(active: true, completed: false)
      outages = outages.where("end_time > now()")
      outages = outages.where("(start_time - interval '1 hour' ) <= now()")
      # TODO: Confirm this works
      # We need to understand how Postgres/Rails handles dates and whether
      # we can do date comparisons using database functions such as now()
      # TODO: This will exclude all outages in the past - is this a good idea
      # ----------- IMPORTANT --------------------------------------------------

      # puts "generate_background_events.rb TP_#{__LINE__}:SQL: #{outages.to_sql}"

      outages.each do |o|
        # puts "TP_#{__LINE__}: START: #{o.start_time}"
        last_reminder_event = o.events.where(event_type: :reminder)
                              .order(created_at: :desc).first

        if last_reminder_event.nil?
          # TODO: This will only generate 1 reminder event per outage,
          # likely want more flexible functionality than this
          # Doesn't take into account users setting reminders/watches after
          # the reminder period

          reminder_events << o.events.create(event_type: "reminder",
                                             text: "Outaged Scheduled to Begin at #{o.start_time.to_s(:iso8601)}",
                                             handled: false)
        end
      end

      reminder_events
    end

    def self.check_for_overdue_outages
      overdue_events = []
      outages = Outage.where(active: true, completed: false)
      outages = outages.where("end_time < now()") # TODO: Confirm this works
      # We need to understand how Postgres/Rails handles dates and whether
      # we can do date comparisons using database functions such as now()
      # ----------- IMPORTANT --------------------------------------------------

      # puts "generate_background_events.rb TP_#{__LINE__}:SQL: #{outages.to_sql}"
      outages.each do |o|
        last_overdue_event = o.events.where(event_type: :overdue)
                              .order(created_at: :desc).first
        last_completed_event = o.events.where(event_type: :completed)
                                .order(created_at: :desc).first

        if last_overdue_event.nil? ||
           (!last_completed_event.nil? &&
             last_overdue_event.created_at < last_completed_event.created_at)

          overdue_events << o.events.create(event_type: "overdue",
                                          text: "Outage Not Completed As Scheduled",
                                          handled: false)
        end
      end
      overdue_events
    end
  end
end
