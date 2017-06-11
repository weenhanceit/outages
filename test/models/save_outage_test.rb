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
    assert_difference "Event.count" do
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."

      assert_equal "outage", event.event_type
      assert_equal "New outage", event.text
      assert_equal outage, event.outage
    end
  end

  test "save a new invalid outage" do
    flunk
  end

  test "save an existing but now invalid outage" do
    flunk
  end

  test "save an existing unchanged outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    assert_no_difference "Event.count" do
      result = Services::SaveOutage.call(outage),
               "Save outage #{outage.inspect} failed."
      assert true == result
    end
  end

  test "change start time of existing outage" do
    flunk
  end
end
