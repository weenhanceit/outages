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

  test "can't remove account admin from last account admin" do
    user = new_user(privilege_account: true)
    user.privilege_account = false
    assert !user.save
    assert ["This is the last account manager"], user.errors
  end

  test "can't remove user admin from last user admin" do
    user = new_user(privilege_manage_users: true)
    user.privilege_manage_users = false
    assert !user.save
    assert ["This is the last user manager"], user.errors
  end

  test "can't remove last account admin" do
    user = new_user(privilege_account: true)
    user.active = false
    assert !user.save
    assert ["This is the last account manager"], user.errors
  end

  test "can't remove last user admin" do
    user = new_user(privilege_manage_users: true)
    user.active = false
    assert !user.save
    assert ["This is the last user manager"], user.errors
  end

  test "user display name is name if name present" do
    user = new_user
    user.name = "My Name"
    user.email = "test@example.com"
    assert_equal user.name, user.display_name
  end

  test "user display name is email if name not present" do
    user = new_user
    user.email = "test@example.com"
    user.name = nil
    assert_equal user.email, user.display_name
  end

  private

  def new_user(attrs={})
    account = Account.create!(name: "Test")
    account.users.create!({ email: "a@example.com",
                            name: "A",
                            notification_periods_before_outage: 1,
                            notification_period_interval: "hours",
                            notify_me_before_outage: false,
                            notify_me_on_note_changes: false,
                            notify_me_on_outage_changes: true,
                            notify_me_on_outage_complete: true,
                            notify_me_on_overdue_outage: false,
                            password: "password",
                            preference_email_time: "8:00",
                            preference_individual_email_notifications: false,
                            preference_notify_me_by_email: false,
                            privilege_account: false,
                            privilege_edit_cis: false,
                            privilege_edit_outages: false,
                            privilege_manage_users: false }.merge(attrs))
  end
end
