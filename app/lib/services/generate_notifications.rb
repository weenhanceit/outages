module Services
  class GenerateNotifications
    def self.call

      events_to_handle = Event.where(handled: false)
      events_to_handle.each do |event|
        event.outage.watches.each do |watch|
          puts "outage watch: #{watch.inspect}"
        end
        event.outage.cis.map(&:watches).flatten.each do |watch|
          puts "ci watch: #{watch.inspect}"
        end
      end
    end
  end
end
