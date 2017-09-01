module Services
  class SaveOutage
    ##
    # Returns true if no event was generated, and either the outage was
    # saved successfully, or it hadn't changed and therefore didn't need
    # to be saved.
    # Returns an array of events if any events were generated and the outage
    # was saved successfully.
    # Returns false if the outage save failed (typically because the data
    # was invalid).
    def self.call(outage)
      unless outage.is_a?(Outage)
        raise ArgumentError, "Services::SaveOutage.call: Expected Outage, got #{outage.class}"
      end
      # puts "-xxyeh- save_outage.rb: TP_#{__LINE__}"

      outage_event = outage_event_text(outage)
      completed_event = completed_event_text(outage)
      # puts "Line: #{__LINE__}: outage_event: #{outage_event} completed_event: #{completed_event}"
      # puts "-xxyeh- save_outage.rb: TP_#{__LINE__} event text: #{outage_event_text}"
      return false unless outage.save
      # puts "-xxyeh- save_outage.rb: TP_#{__LINE__}"

      changes = outage.previous_changes
      # puts "changes: #{changes}"

      # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"
      Jobs::ReminderJob.schedule(outage) if changes[:start_time].present?
      Jobs::OverdueJob.schedule(outage) if changes[:end_time].present?

      events = []
      # puts "Line: #{__LINE__}: events size: #{events.size}"
      if outage_event
        events << Services::GenerateNotifications.create_event_and_notifications(outage,
          "outage",
          outage_event)
      end
      if completed_event
        events << Services::GenerateNotifications.create_event_and_notifications(outage,
          "completed",
          completed_event)
      end

      return true if events.empty?
      events
      # puts "-xxyeh- save_outage.rb: TP_#{__LINE__}"

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

    def self.outage_event_text(outage)
      determine_event_text(outage)[:outage]
    end

    def self.completed_event_text(outage)
      determine_event_text(outage)[:completed]
    end

    def self.determine_event_text(outage)
      # puts "save_outage.rb TP_#{__LINE__}: outage new: #{outage.new_record?} active: #{outage.active}"

      results = { outage: nil, completed: nil }

      # New outages
      if outage.new_record?
        # New Record is active
        if outage.active
          results[:outage] = "New Outage"
          results[:completed] = "Outage Completed" if outage.completed
        end
      else
        # Save of existing records
        # Outage changed and is now active (Equivalent to New outages)
        if outage.changed? && outage.became_inactive?
          results[:outage] = "Outage Cancelled"
        elsif outage.changed? && outage.became_active?
          results[:outage] = "Outage Reactivated"
          results[:completed] = "Outage Completed" if outage.completed
        elsif outage.changed? && !outage.became_incompleted? &&
              !outage.became_completed?
          results[:outage] = "Outage Changed"
        elsif outage.changed? && outage.became_incompleted?
          # puts "save_outage.rb #{__LINE__}: "
          results[:outage] = "Outage Changed" unless outage.only_completed_changed?
          results[:completed] = "Outage No Longer Completed"
        elsif outage.changed? && outage.became_completed?
          results[:outage] = "Outage Changed" unless outage.only_completed_changed?
          results[:completed] = "Outage Completed"
        end
      end

      # puts "save_outage.rb TP_#{__LINE__}: inspect results: #{results.inspect}"

      results
    end

    # def self.event_text (outage)
    #   # puts "-xxyeh- save_outage.rb: TP_#{__LINE__}"
    #   # puts "-xxyeh- New: #{outage.new_record?} Active: #{outage.active} Changed: #{outage.changed?} Active Changed: #{outage.active_changed?}"
    #   if outage.new_record? && outage.active
    #     "New Outage"
    #   elsif !outage.new_record? && outage.changed?
    #     if !outage.active_changed? && outage.active
    #       "Outage Changed"
    #     elsif outage.active_changed? && !outage.active
    #       "Outage Cancelled"
    #     elsif outage.active_changed? && outage.active
    #       "New Outage"
    #     end
    #   end
    # end
  end
end
