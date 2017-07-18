##
# A creation, change, or deletion of an outage, or its attached notes.
class Event < ApplicationRecord
  enum event_type: [:outage, :note, :completed, :overdue, :reminder]

  validates :handled,
    inclusion: { in: [true, false], message: "can't be blank" }

  has_many :notifications, dependent: :destroy
  belongs_to :outage, -> { unscope(where: :active) }
end
