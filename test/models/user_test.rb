require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validate presence of active" do
    user = User.new
    assert_not user.valid?, "Valid when it should be invalid."
    # We need to set defaults for when Devise creates the User.
    assert_equal [
      # "Account must exist",
      # "Active can't be blank", Default scope means this can't happen
      "Email can't be blank",
      # "Notify me before outage can't be blank",
      # "Notify me on note changes can't be blank",
      # "Notify me on outage changes can't be blank",
      # "Notify me on outage complete can't be blank",
      # "Notify me on overdue outage can't be blank",
      "Password can't be blank" # ,
      # "Preference individual email notifications can't be blank",
      # "Preference notify me by email can't be blank",
      # "Privilege account can't be blank",
      # "Privilege edit cis can't be blank",
      # "Privilege edit outages can't be blank",
      # "Privilege manage users can't be blank"
    ], user.errors.full_messages.sort
  end

  test "get all outages watched by user" do
    user = users(:edit_ci_outages)
    assert_equal [
      outages(:company_a_outage_watched_by_edit),
      outages(:company_a_outage_ci_watched_by_edit),
      outages(:company_a_outage_c)
    ].sort, user.outages.sort
  end
end
