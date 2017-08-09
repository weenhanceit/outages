module Services
  class SaveUser
    ##
    # Saves user and schedules jobs if necessary.
    def self.call(user)
      unless user.is_a?(User)
        raise ArgumentError,
          "Services::SaveUser.call: Expected User, got #{user.class}"
      end

      return false unless user.save

      changes = user.previous_changes
      # puts "changes: #{changes}"
      # puts changes[:notify_me_before_outage].present?
      # puts "User ID saved: #{user.id}"
      if (changes[:notify_me_before_outage].present? ||
        changes[:notification_periods_before_outage].present? ||
        changes[:notification_period_interval].present?) &&
        user.notify_me_before_outage
        # puts "Scheduling."
        Jobs::ReminderJob.schedule(user.outages, user)
      end

      if changes[:notify_me_on_overdue_outage].present? &&
        user.notify_me_on_overdue_outage
        # puts "Scheduling."
        Jobs::OverdueJob.schedule(user.outages, user)
      end

      user
    end
  end
end
