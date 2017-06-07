##
# Free-form text that can be attached to a CI or an outage to identify it
# in a user-defined way.
class Tag < ApplicationRecord
  belongs_to :account
  belongs_to :taggable, polymorphic: true
end
