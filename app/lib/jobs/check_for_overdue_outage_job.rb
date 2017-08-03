module Jobs
  class CheckForOverdueOutageJob < ApplicationJob
    def perform(outage)
      outage_now = Outage.find(outage.id)
      return if job_invalid?(outage, outage_now)

      # TODO: This could be a method `create_unique_overdue` on Event.
      e = Event.find_or_create_by(outage: outage_now,
                                  event_type: "overdue",
                                  handled: false) do |e|
        e.text = "Outage Not Completed As Scheduled"
      end
    end

    def self.schedule(outage)
      set(wait_until: outage.end_time).perform_later(outage)
    end

    private

    ##
    # Check that changes to the outage haven't made this job unnecessary.
    #
    # * Outage is active and not completed
    # * Outage starts at the same time as when this job was scheduled
    def job_invalid?(outage, outage_now)
      outage.end_time != outage_now.end_time ||
        outage_now.completed ||
        !outage_now.active
    end
  end
end
