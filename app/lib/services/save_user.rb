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
        # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"

        Jobs::ReminderJob.schedule(user.outages, user)
      end

      if changes[:notify_me_on_overdue_outage].present? &&
        user.notify_me_on_overdue_outage
        # puts "Scheduling."
        Jobs::OverdueJob.schedule(user.outages, user)
      end

      if changes[:preference_notify_me_by_email].present? &&
        user.preference_notify_me_by_email ||
        changes[:preference_individual_email_notifications].present? &&
        !user.preference_individual_email_notifications ||
        changes[:preference_email_time].present?
        # puts "Scheduling."
        Jobs::EmailJob.schedule(user)
      end

      user
    end
  end
end
