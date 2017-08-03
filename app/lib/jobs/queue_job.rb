# TODO: Remove if I'm not actually using this.
module Jobs
  ##
  # Job to manage the notifications that are triggered based on time.
  class QueueJob < ApplicationJob
    # If the Queue entry has been deleted for this job, ignore the exception
    # and do nothing.
    rescue_from(ActiveJob::DeserializationError) do |_exception|
      logger.debug("QueueJob ran for action that had been destroyed.")
    end
  end
end
