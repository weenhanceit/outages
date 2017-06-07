##
# A notification to be delivered to a user, for a watch, based on an event.
# The notification includes the delivery method, so that there may
# be a notification for e-mail and a notification for on-line presentation,
# for a single event.
class Notification < ApplicationRecord
  enum notification_type: [:online, :email]

  belongs_to :event
  belongs_to :watch
end
