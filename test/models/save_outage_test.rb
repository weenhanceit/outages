require "test_helper"

class SaveOutageTest < ActiveSupport::TestCase
  test "save a new valid outage" do
    outage = Outage.new(account: accounts(:company_a),
                        causes_loss_of_service: true,
                        completed: false,
                        description: "Company A outage for save test",
                        end_time: Time
                          .find_zone("Samoa")
                          .parse("2017-08-30T15:00:00"),
                        name: "Outage for save test",
                        start_time: Time
                          .find_zone("Samoa")
                          .parse("2017-08-30T14:00:00"))
    assert_difference ["Event.count","Outage.count"] do
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."

      assert_equal "outage", event.event_type
      assert_equal "New Outage", event.text
      assert_equal outage, event.outage
    end
  end

  test "save a new invalid outage" do
    outage = Outage.new
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert_not result
    end

  end

  test "save an existing but now invalid outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.active = nil
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert_not result
    end
  end

  test "save an existing unchanged outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert true == result
    end
  end

  test "change start time of existing outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.start_time = outage.start_time + 14.minute
    assert_difference "Event.count" do
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "Outage Changed", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    outage_saved = Outage.find(outage.id)
    assert outage_saved.is_a?(Outage), "Could not find saved outage"
    assert_equal outage.start_time, outage_saved.start_time, "Start time unchanged"
  end

  test "make active outage inactive" do
    outage = outages(:company_a_outage_watched_by_edit)
    assert_difference "Event.count" do
      outage.active = false
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "Outage Cancelled", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    assert_equal 0, Outage.where(id: outage.id).size
    outage.reload
    assert_not outage.active
  end

  test "make inactive outage active" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.active = false
    outage.save
    assert_difference "Event.count" do
      outage.active = true
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "New Outage", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    outage_saved = Outage.find(outage.id)
    assert outage_saved.is_a?(Outage), "Could not find saved outage"
  end

end
