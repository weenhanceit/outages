require "test_helper"

class EventTest < ActiveSupport::TestCase

  test "retreive event with inactive outage" do
    skip
    event = events(:company_a_outage_a_event_a)
    event.outage.active = false
    assert event.outage.save
    event.reload
# puts "Outage Name: #{event.outage.name} Active: #{event.outage.active}"
    assert_equal 0, Event.where(id: event.id).size
  end

  test "validators" do
    event = Event.new
    assert_not event.valid?, "Valid when it should be invalid."
    assert_equal [
      "Handled can't be blank",
      "Outage must exist"
    ], event.errors.full_messages.sort
  end
end
