require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "validators" do
    event = Event.new
    assert_not event.valid?, "Valid when it should be invalid."
    assert_equal [
      "Handled can't be blank",
      "Outage must exist"
    ], event.errors.full_messages.sort
  end
end
