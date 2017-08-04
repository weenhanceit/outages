require "test_helper"

class ReminderJobTest < ActiveJob::TestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "watch on CI, create outage, get reminder" do
    # Remember to round the time so it will compare correctly after it's
    # been stored in the database.
    start_time = Time.zone.now.round
    outage = @account.outages.build(
      name: "Outage",
      start_time: start_time,
      end_time: start_time + 30.minutes,
      causes_loss_of_service: true,
      completed: false
    )
    outage.cis_outages.build(ci: @ci)
    assert_enqueued_jobs 1, only: Jobs::ReminderJob do
      Services::SaveOutage.call(outage)
    end

    perform_enqueued_jobs do
      assert_difference "Event.count" do
        assert_difference "Notification.count", 2 do
          Jobs::ReminderJob.perform_now(@user, outage)
        end
      end
    end
  end

  test "add watch to outage, get reminder" do
    outage = make_outage(Time.zone.now.round + 10.minutes)
    assert_no_enqueued_jobs
    assert_enqueued_jobs 1 do
      outage.watches.create!(user: @user)
    end
  end

  test "outage starts earlier than originally planned" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 1.day)

    assert_no_enqueued_jobs
    outage.start_time -= 23.hours + 30.minutes
    outage.end_time -= 23.hours + 30.minutes
    assert_enqueued_jobs 1, only: Jobs::ReminderJob do
      Services::SaveOutage.call(outage)
    end
  end

  test "outage starts later than originally planned" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 5.minutes)

    assert_enqueued_jobs 1, only: Jobs::ReminderJob
    outage.start_time += 23.hours + 30.minutes
    outage.end_time += 23.hours + 30.minutes
    assert_no_enqueued_jobs only: Jobs::ReminderJob do
      Services::SaveOutage.call(outage)
    end
    # TODO: Should we run the job here to make sure it doesn't do anything?
  end

  test "user stops asking for reminders" do
    outage = make_outage_with_ci_watch()
    assert_enqueued_jobs 1, only: Jobs::ReminderJob
    @user.notify_me_before_outage = false
    @user.save!
    assert_no_difference "Notification.count" do
      assert_performed_jobs 1, only: Jobs::ReminderJob
    end
  end

  test "user asks for reminders with existing outage" do
    @user.notify_me_before_outage = false
    @user.save!
    outage = make_outage_with_ci_watch(Time.zone.now + 2.hours)
    assert_no_enqueued_jobs only: Jobs::ReminderJob
    @user.notify_me_before_outage = true
    @user.save!
    assert_enqueued_jobs 1, only: Jobs::ReminderJob
    assert_difference "Notification.count" do
      assert_performed_jobs 1, only: Jobs::ReminderJob
    end
  end

  test "user stops watching outage" do
    outage = make_outage(Time.zone.now.round + 10.minutes)
    assert_no_enqueued_jobs
    assert_enqueued_jobs 1 do
      watch = outage.watches.create!(user: @user)
      outage.watches.find(watch.id).destroy
      outage.save!
    end
    assert_no_difference "Notification.count" do
      assert_performed_jobs 1, only: Jobs::ReminderJob
    end
  end

  test "user stops watching CI of outage" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 10.minutes)
    assert_enqueued_jobs 1, only: Jobs::ReminderJob
    outage.watches.destroy_all
    outage.save!
    assert_no_difference "Notification.count" do
      assert_performed_jobs 1, only: Jobs::ReminderJob
    end
  end

  private

  def make_outage(start_time = Time.zone.now.round)
    @account.outages.create!(
      name: "Outage",
      start_time: start_time,
      end_time: start_time + 30.minutes,
      causes_loss_of_service: true,
      completed: false
    )
  end

  def make_outage_with_ci_watch(start_time = Time.zone.now.round)
    outage = make_outage(start_time)
    outage.cis_outages.create!(ci: @ci)
    outage
  end

  def setup # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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
    @ci = @account.cis.create!(name: "CI")
    @user.watches.create!(watched: @ci)
  end
end
