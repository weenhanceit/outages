module Jobs
  class EmailJob < ApplicationJob
    class << self
      def schedule(user)
        if user.preference_notify_me_by_email &&
           !user.preference_individual_email_notifications
          t = Time.zone.now.change(hour: user.preference_email_time.hour,
                                   min: user.preference_email_time.min,
                                   sec: user.preference_email_time.sec)
          t += 1.day if t.past?
          set(wait_until: t).perform_later(user)
        end
      end

      def job_invalid?(user, user_now)
        user.preference_notify_me_by_email !=
          user_now.preference_notify_me_by_email ||
          user.preference_individual_email_notifications !=
            user_now.preference_individual_email_notifications ||
          user.preference_email_time !=
            user_now.preference_email_time
      end
    end

    def perform(user)
      user_now = User.find(user.id)
      return if EmailJob.job_invalid?(user, user_now)
      # puts "Job is valid."
      NotificationMailer.notification_email(user_now)
      # puts "Emails created."
    end
  end
end
