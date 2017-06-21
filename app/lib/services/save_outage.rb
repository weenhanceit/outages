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
      unless outage.is_a?(Outage)
        raise ArgumentError, "Services::SaveOutage.call: Expected Outage, got #{outage.class}"
      end

      use_event_text = event_text(outage)
      return false unless outage.save

      return true unless use_event_text

      outage.events.create(event_type: "outage",
                           text: use_event_text,
                           handled: false)

      # if outage.new_record?
      #   return false unless outage.save
      #   outage.events.create(event_type: "outage",
      #    text: "New outage",
      #    handled: false)
      # elsif outage.changed?
      #   return false unless outage.save
      #   outage.events.create(event_type: "outage",
      #    text: "Outage Changed",
      #    handled: false)
      # else
      #   true
      # end
    end

    private

    def self.event_text (outage)
      if outage.new_record? && outage.active
        "New Outage"
      elsif !outage.new_record? && outage.changed?
        if !outage.active_changed? && outage.active
          "Outage Changed"
        elsif outage.active_changed? && !outage.active
          "Outage Cancelled"
        elsif outage.active_changed? && outage.active
          "New Outage"
        end
      end
    end
  end
end
