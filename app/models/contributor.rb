##
# Indicates that a user has contributed something to an outage.
class Contributor < ApplicationRecord
  belongs_to :user
  belongs_to :outage
end
