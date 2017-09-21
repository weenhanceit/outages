module Jobs
  class EmailJob < ApplicationJob
    class << self
      ##
      # Queue up an EmailJob for a user, if the user want to receive
      # notifications by email and wants those notifications sent
      # in a single daily batch
      def schedule(user)
        # puts "ej.rb #{__LINE__}:"
        if user.preference_notify_me_by_email &&
           !user.preference_individual_email_notifications
          t = Time.zone.now.change(hour: user.preference_email_time.hour,
                                   min: user.preference_email_time.min,
                                   sec: user.preference_email_time.sec)
          # puts "ej.rb #{__LINE__}: #{t}"
          t += 1.day if t.past?
          set(wait_until: t).perform_later(user)
        end
      end

      ##
      # Check if the job should still execute, or if changes since being
      # scheduled have invalidated it.
      #
      # * The user hasn't changed the time they want to get e-mails.
      # * The user still wants e-mail notifications.
      # * The user still wants batched e-mails.

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
      # puts " ---- email_job.rb #{__LINE__} ----S"
      user_now = User.find(user.id)
      return if EmailJob.job_invalid?(user, user_now)
      # puts "Job is valid."
      email = NotificationMailer.notification_email(user_now)
      # puts "Emails created."
      EmailJob.schedule(user)
      email
    end
  end
end
