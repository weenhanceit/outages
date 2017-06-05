class EventPublisher
  def event_trigger(event_details)
    event = Event.new
    event.save
  end

  def self.outage_changed
    event_trigger(user_id, ...)
  end

  def self.note_changed
    event_trigger(user_id, ...)
  end

  def self.outage_completed
    event_trigger(user_id, ...)
  end

  def self.outage_not_completed_on_time
    event_trigger(user_id, ...)
  end

end

class OutageEventPublisher
  def event_trigger(outage_id, event_type, event_text = "something changed.")
    event = Event.new(outage_id, event_type, event_text)
    event.save
  end
end
