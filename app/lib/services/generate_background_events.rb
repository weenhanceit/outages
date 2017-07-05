module Services
  # Class with methods for background handling of events and notifications
  class GenerateBackgroundEvents
    def self.call
      events = []

      next_event = check_for_overdue_outages
      events << next_event unless next_event.nil?

      next_event = check_for_outage_reminders
      events << next_event unless next_event.nil?

      events
    end

    def self.check_for_outage_reminders
      reminder_event = nil
      reminder_event
    end

    def self.check_for_overdue_outages
      overdue_event = nil
      outages = Outage.where(active: true, completed: false)
      outages = outages.where("end_time < now()")

      # puts "generate_background_events.rb TP_#{__LINE__}:SQL: #{outages.to_sql}"
      outages.each do |o|
        last_overdue_event = o.events.where(event_type: :overdue)
                              .order(created_at: :desc).first
        last_completed_event = o.events.where(event_type: :completed)
                                .order(created_at: :desc).first

        if last_overdue_event.nil? ||
           (!last_completed_event.nil? &&
             last_overdue_event.created_at < last_completed_event.created_at)

          overdue_event = o.events.create(event_type: "overdue",
                                          text: "Outage Not Completed As Scheduled",
                                          handled: false)
        end
      end
      overdue_event
    end
  end
end
