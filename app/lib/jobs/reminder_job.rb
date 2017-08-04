module Jobs
  class ReminderJob < ApplicationJob
    # TODO: This has to go with watches not users.
    def perform(user, outage)
      # Create an event if needed (but watch for races).
      # If all is good, generate notification(s) for the user.
      outage_now = Outage.find(outage.id)
      user_now = User.find(user.id)
      puts "Got current outage and user."
      return if job_invalid?(outage, outage_now, user, user_now)
      puts "Job is valid."
      Services::GenerateNotifications.create_reminder(user_now, outage_now)
      puts "Notifications created."
    end

    ##
    # Schedule reminders for an outage.
    def self.schedule(outage)
      puts "Scheduling: #{outage.inspect} for #{outage.users.inspect}"
      outage.users.each do |user|
        if user.notify_me_before_outage
          puts "SCHEDULING IT."
          t = outage.start_time -
              user
              .notification_periods_before_outage
              .send(user.notification_period_interval.to_sym)
          set(wait_until: t).perform_later(user, outage)
        end
      end
    end

    private

    ##
    # Check that the user should still be notified that this outage is
    # about to start:
    #
    # * Outage is active and not completed
    # * Outage starts at the same time as when this job was scheduled
    # * The user notification period hasn't changed
    # * TODO: Is the user still watching this outage?
    def job_invalid?(outage, outage_now, user, user_now)
      # puts "outage.start_time != outage_now.start_time: #{outage.start_time != outage_now.start_time}"
      # puts "outage_now.completed: #{outage_now.completed}"
      # puts "!outage_now.active: #{!outage_now.active}"
      # puts "user.notification_periods_before_outage != user_now.notification_periods_before_outage: #{user.notification_periods_before_outage != user_now.notification_periods_before_outage}"
      # puts "user.notification_period_interval != user_now.notification_period_interval: #{user.notification_period_interval != user_now.notification_period_interval}"
      outage.start_time != outage_now.start_time ||
        outage_now.completed ||
        !outage_now.active ||
        user.notification_periods_before_outage !=
          user_now.notification_periods_before_outage ||
        user.notification_period_interval !=
          user_now.notification_period_interval
    end
  end
end
