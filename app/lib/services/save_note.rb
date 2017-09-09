module Services
  # Saves a note and generates associated events and notifications
  # Returns true if the note was successfully saved, false otherwise
  # Creates :outage_note event, if the notable object is an Outage
  # If an event is created, notifications are generated for all users
  # watching the outage, directly or indirectly
  class SaveNote
    def self.call(note)
      # Determine if this a note associated with an outage or a ci
      associated_object = note.notable

      event_text = nil
      event_text = "Note Added" if note.new_record?
      event_text = "Note Modified" if !note.new_record? && note.changed?

      # puts "#{__FILE__} Line #{__LINE__}: ---Assoc: #{associated_object.class}"
      # puts "#{__FILE__} Line #{__LINE__}: ---Event: #{event_text}"

      results = note.save
      if results && event_text && associated_object.is_a?(Outage)
        # puts "#{__FILE__} Line #{__LINE__}: ---"
        Services::GenerateNotifications.create_event_and_notifications(associated_object,
                                                                       :outage_note,
                                                                       event_text)
      end
      results
    end

    def self.destroy(note)
      # Determine if this a note associated with an outage or a ci
      associated_object = note.notable

      results = note.destroy
      if results && associated_object.is_a?(Outage)
        # puts "#{__FILE__} Line #{__LINE__}: ---"
        Services::GenerateNotifications.create_event_and_notifications(associated_object,
                                                                       :outage_note,
                                                                       "Note Deleted")
      end

      results
    end
  end
end
