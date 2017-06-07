##
# A creation, change, or deletion of an outage, or its attached notes.
class Event < ApplicationRecord
  enum event_type: [:outage, :note, :completed, :overdue, :reminder]

  belongs_to :outage
end
