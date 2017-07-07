require "test_helper"

class GenerateBackgroundEventsTest < ActiveSupport::TestCase
  test "no overdue event generated" do
    # Make sure other fixtures do not create events
    mark_all_existing_outages_inactive
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set up outage to start and end before now
      start_time = Time.zone.now - 2.hours
      end_time = Time.zone.now + 10.seconds
      # This outage should not generate an event
      setup_outage start_time, end_time

      # This test condition will generate a reminder (because it has not ended)
      # So we need to check no overdue events where generated
      # puts "TP_#{__LINE__}: #{Event.where(event_type: :overdue).size}"
      assert_no_difference "Event.where(event_type: :overdue).size" do
        events = Services::GenerateBackgroundEvents.call
        # puts "TP_#{__LINE__} EVENTS: #{events.inspect}"
        assert_equal 1, events.size, "Unexpected number of events generated"
        assert_equal "reminder", events.first.event_type
        # puts "TP_#{__LINE__}: #{Event.where(event_type: :overdue).size}"
      end
    end
  end

  test "single overdue event generated" do
    # Make sure other fixtures do not create events
    mark_all_existing_outages_inactive
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set up outage to start and end before now
      start_time = Time.zone.now - 2.hours
      end_time = Time.zone.now - 1.second
      # This outage should generate an event
      setup_outage start_time, end_time

      # This outage will have start and end time that would generate an event
      # but is inactive
      inactive_outage = setup_outage start_time, end_time
      inactive_outage.active = false
      inactive_outage.save

      assert_difference "Event.all.size" do
        events = Services::GenerateBackgroundEvents.call
        assert_equal 1, events.size, "Unexpected number of events generated"

        # Next call should not generate any events
        events = Services::GenerateBackgroundEvents.call
        # puts "Events: #{events.inspect}"
        assert_equal 0, events.size, "No new events should be generated"
      end
    end
  end

  test "outage complete to incomplete to complete generates new event" do
    # Make sure other fixtures do not create events
    mark_all_existing_outages_inactive
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set up outage to start and end before now
      start_time = Time.zone.now - 2.hours
      end_time = Time.zone.now - 1.second
      # This outage should generate an event
      outage = setup_outage start_time, end_time

      # This outage will have start and end time that would generate an event
      # but is inactive
      inactive_outage = setup_outage start_time, end_time
      inactive_outage.active = false
      inactive_outage.save

      assert_difference "Event.all.size", 4 do
        # This should generate event 1 of 4
        events = Services::GenerateBackgroundEvents.call
        assert_equal 1, events.size, "Unexpected number of events generated"
        assert_equal "overdue", events.first.event_type,
          "Should be an overdue event"

        # Next call should not generate any events
        events = Services::GenerateBackgroundEvents.call
        assert_equal 0, events.size, "No new events should be generated"

        # Set outage complete and save, this should generate
        # a new completed event
        # This should generate event 2 of 4
        outage.completed = true
        events = Services::SaveOutage.call(outage)
        # puts "EVENTS: #{events.inspect}"
        assert_equal 1, events.size, "Outage complete should generate 1 event"
        assert_equal "completed", events.first.event_type,
          "Should be a completed event"

        # This should generate event 3 of 4
        outage.completed = false
        events = Services::SaveOutage.call(outage)
        # puts "EVENTS: #{events.inspect}"
        assert_equal 1, events.size, "Outage incomplete should generate 1 event"
        assert_equal "completed", events.first.event_type,
          "Should be a completed event"

        # This should generate event 4 of 4
        events = Services::GenerateBackgroundEvents.call
        assert_equal 1, events.size, "Unexpected number of events generated"
        assert_equal "overdue", events.first.event_type,
          "Should be an overdue event"
      end
    end
  end

  test "single reminder generated" do
    # Make sure other fixtures do not create events
    mark_all_existing_outages_inactive
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # This outage should generate an event
      setup_outage Time.zone.now + 59.minutes, Time.zone.now + 4.hours

      # This outage should not generate an event
      setup_outage Time.zone.now + 2.hours, Time.zone.now + 4.hours

      # This outage will have start and end time that would generate an event
      # but is inactive
      inactive_outage = setup_outage Time.zone.now - 1.hour,
        Time.zone.now + 2.hours
      inactive_outage.active = false
      inactive_outage.save

      assert_difference "Event.all.size" do
        events = Services::GenerateBackgroundEvents.call
        # puts "TP_#{__LINE__} EVENTS: #{events.inspect}"
        assert_equal 1, events.size, "Unexpected number of events generated"
        assert_equal "reminder", events.first.event_type,
          "Should be a reminder"

        # Next call should not generate any events
        events = Services::GenerateBackgroundEvents.call
        # puts "TP_#{__LINE__} EVENTS: #{events.inspect}"
        assert_equal 0, events.size, "No new events should be generated"
      end
    end
  end

  private

  def mark_all_existing_outages_inactive
    Outage.all.each do |o|
      o.active = false
      o.save
    end
  end

  def setup_outage(start_time = Time.zone.now, end_time = Time.zone.now + 1.hour)
    outage = Outage.create(account: accounts(:company_a),
                           causes_loss_of_service: true,
                           completed: false,
                           description: "Company A Test Outage -\
                                         generate_background_events_test.rb",
                           end_time: end_time,
                           name: "Company A Test Outage",
                           start_time: start_time)
    assert outage.save
    outage
  end
end
