require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test "job sends an email when run" do
    # Ensure the user prefers batch emails
    @user.preference_individual_email_notifications = true
    @user.preference_notify_me_by_email = true
    @user.save!
    email = nil
    assert_emails 1 do
      email = Jobs::EmailJob.perform_now(@user)
      assert email, "Job should have sent an email"
      puts "class: #{email.class}"
    end

    assert_equal ["noreply@weenhanceit.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Latest Notifications from Outages App", email.subject

    flunk
  end

  private
  def setup # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      @account = Account.create!(name: "Email Corp")
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
                       # encrypted_password:
                       #   User.new.send(:password_digest, "password"),
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
      # @ci = @account.cis.create!(name: "CI")
      # @user.watches.create!(watched: @ci)
    end
  end
end
