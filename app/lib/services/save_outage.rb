module Services
  class SaveOutage
    ##
    # Returns true if no event was generated, and either the outage was
    # saved successfully, or it hadn't changed and therefore didn't need
    # to be saved.
    # Returns an event if an event was generated and the outage was saved
    # successfully.
    # Returns nil or false if the outage save failed (typically because the data
    # was invalid).
    def self.call(outage)
      if outage.new_record?
        return false unless outage.save
        outage.events.create(event_type: "outage", text: "New outage", handled: false)
      elsif outage.changed?
        false
      else
        true
      end
    end
  end
end
