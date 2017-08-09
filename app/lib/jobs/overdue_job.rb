module Jobs
  class OverdueJob < ApplicationJob
    class << self
      def schedule(outages, users = [])
        outages = [outages] unless outages.is_a?(Array)
        users = [users] unless users.is_a?(Array)
        outages.each do |outage|
          (users.empty? ? outage.users : users).each do |user|
            if user.notify_me_on_overdue_outage
              set(wait_until: outage.end_time).perform_later(user, outage)
            end
          end
        end

        private

        def job_invalid?(outage, outage_now, user, user_now)
          Watch.unique_watch_for(user, outage).nil? ||
            outage.start_time != outage_now.start_time ||
            outage_now.completed ||
            !outage_now.active ||
            user.notify_me_on_overdue_outage !=
              user_now.notify_me_on_overdue_outage
        end
      end
    end

    def perform(user, outage)
      outage_now = Outage.find(outage.id)
      user_now = User.find(user.id)
      # puts "Got current outage and user."
      return if OverdueJob.job_invalid?(outage, outage_now, user, user_now)
      # puts "Job is valid."
      Services::GenerateNotifications.create_overdue(user_now, outage_now)
      # puts "Notifications created."
    end
  end
end
