require "test_helper"

class ReminderJobTest < ActiveJob::TestCase
  test "watch on CI, create outage, get reminder" do
    # Remember to round the time so it will compare correctly after it's
    # been stored in the database.
    outage_start = Time.zone.now.round
    outage = @account.outages.create!(
      name: "Outage",
      start_time: outage_start,
      end_time: outage_start + 30.minutes,
      causes_loss_of_service: true,
      completed: false
    )
    outage.cis_outages.create!(ci: @ci)

    assert_difference "Event.count" do
      assert_difference "Notification.count", 2 do
        Jobs::ReminderJob.perform_now(@user, outage)
      end
    end
  end

  test "add watch to outage, get reminder" do
    flunk
  end

  test "outage starts earlier than originally planned" do
    flunk
  end

  test "outage starts later than originally planned" do
    flunk
  end

  test "user stops asking for reminders" do
    flunk
  end

  test "user asks for reminders with existing outage" do
    flunk
  end

  test "user stops watching outage" do
    flunk
  end

  test "user stops watching CI of outage" do
    flunk
  end

  private

  def setup
    @account = Account.create!(name: "Reminders")
    @user = @account
            .users
            .create!(email: "user@weenhanceit.com",
                     name: "user",
                     notification_periods_before_outage: 1,
                     notification_period_interval: "hours",
                     notify_me_before_outage: true,
                     notify_me_on_outage_changes: true,
                     notify_me_on_note_changes: true,
                     notify_me_on_outage_complete: true,
                     notify_me_on_overdue_outage: true,
                     preference_email_time: "8:00",
                     preference_individual_email_notifications: false,
                     preference_notify_me_by_email: true,
                     privilege_account: false,
                     privilege_edit_cis: false,
                     privilege_edit_outages: false,
                     privilege_manage_users: false,
                     time_zone: "Samoa",
                     password: "password",
                     # encrypted_password: User.new.send(:password_digest, "password"),
                     # reset_password_token:,
                     # reset_password_sent_at:,
                     # remember_created_at:,
                     sign_in_count: 0,
                     # current_sign_in_at:,
                     # last_sign_in_at:,
                     # current_sign_in_ip:,
                     # last_sign_in_ip:,
                     # confirmation_token:,
                     confirmed_at: Time.zone.now - 1.hour,
                     confirmation_sent_at: Time.zone.now - 2.hours,
                     # unconfirmed_email:,
                     failed_attempts: 0,
                    # unlock_token:,
                    # locked_at:
                    )
    @ci = @account.cis.create!(name: "CI")
    @user.watches.create!(watched: @ci)
  end
end
