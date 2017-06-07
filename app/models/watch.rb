##
# Represents a user watching for outages on a CI, or watching an outage
# directly.
class Watch < ApplicationRecord
  belongs_to :user
  belongs_to :watched, polymorphic: true
end
