##
# Free-form text that can be attached to a CI or an outage.
class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :user
end
