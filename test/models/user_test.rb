require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validate presence of active" do
    user = User.new
    assert_not user.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist",
      # "Active can't be blank", Default scope means this can't happen
      "Email can't be blank",
      "Notify me before outage can't be blank",
      "Notify me on outage changes can't be blank",
      "Notify me on note changes can't be blank",
      "Notify me on outage complete can't be blank",
      "Notify me on overdue outage can't be blank",
      "Preference individual email notifications can't be blank",
      "Preference notifiy me by email can't be blank",
      "Privilege account can't be blank",
      "Privilege edit cis can't be blank",
      "Privilege edit outages can't be blank",
      "Privilege manage users can't be blank"
    ], user.errors.full_messages
  end
end
