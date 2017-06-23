##
# A notification to be delivered to a user, for a watch, based on an event.
# The notification includes the delivery method, so that there may
# be a notification for e-mail and a notification for on-line presentation,
# for a single event.
class Notification < ApplicationRecord
  enum notification_type: [:online, :email]

  belongs_to :event
  belongs_to :watch

  default_scope { where.not(watch: nil) }

  scope :unacknowledged, -> { where(notified: false )}

  # This method provides an english text description of the event type
  def event_info
    # TODO: Add text for other event types
    case event.event_type
    when "outage"
      "New Outage / Changed Outage Info"
    else
      "--unknown--"
    end
  end

  # This method provides an english text explaination for why the notification
  # was created.  It is based on the item watched
  def reason
    if watch.watched.is_a?(Ci)
      "You are watching Service: #{watch.watched.name}"
    elsif watch.watched.is_a?(Outage)
      "You are watching Outage: #{watch.watched.name}"
    else
      "-- unknown --"
    end
  end
end
