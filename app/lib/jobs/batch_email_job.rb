module Jobs
  class BatchEmailJob < ApplicationJob
    def perform(user)
      # Then set the next job.
      user_now = User.find(user.id)
      return if job_invalid?(user, user_now)
      # send e-mails
      schedule(user)
    end

    ##
    # Figure out the next time to schedule a batch e-mail job for the user,
    # given that the user may have changed to time at which they want to
    # receive e-mail.
    def self.next_queue_action_time(user)
      Time.use_zone user.time_zone do
        t = Time.zone.today
        next_action_time = user
                           .preference_email_time
                           .change(year: t.year, month: t.month, day: t.day)
        if next_action_time <= Time.zone.now
          next_action_time.change(day: next_action_time.day + 1)
        end
        next_action_time
      end
    end

    ##
    # Schedule the next time to do a batch e-mail run for a user
    def self.schedule(user)
      set(wait_until: next_queue_action_time(user)).perform_later(user)
    end

    private

    ##
    # Check if the job should still execute, or if changes since being
    # scheduled have invalidated it.
    #
    # * The user hasn't changed the time they want to get e-mails.
    # * The user still wants batched e-mails.
    def job_invalid?(user, user_now)
      user.preference_individual_email_notifications ||
        user.preference_email_time != user_now.preference_email_time
    end
  end
end
