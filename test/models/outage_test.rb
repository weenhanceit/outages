require "test_helper"

class OutageTest < ActiveSupport::TestCase
  test "validators" do
    outage = Outage.new
    assert_not outage.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist",
      "Active can't be blank",
      "Causes loss of service can't be blank",
      "Completed can't be blank"
    ], outage.errors.full_messages.sort
  end
end
