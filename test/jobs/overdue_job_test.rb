require "test_helper"

class OverdueJobTest < ActiveJob::TestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "watch on CI, create outage, get overdue notification" do
    # Remember to round the time so it will compare correctly after it's
    # been stored in the database.
    outage = make_outage_with_ci_watch(Time.zone.now.round)
    assert_enqueued_jobs 1, only: Jobs::OverdueJob do
      Services::SaveOutage.call(outage)
    end

    assert_performed_jobs 1 do
      assert_difference "Event.count" do
        assert_difference "Notification.count", 2 do
          Jobs::OverdueJob.perform_later(@user, outage)
        end
      end
    end
  end

  test "watch on outage, get overdue notification" do
    outage = make_outage(Time.zone.now.round + 10.minutes)
    Services::SaveOutage.call(outage)
    assert_no_enqueued_jobs
    assert_enqueued_jobs 1 do
      outage.watches.create!(user: @user)
    end
  end

  test "outage ends earlier than originally planned" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 1.day)
    assert_enqueued_with(job: Jobs::OverdueJob, at: outage.end_time) do
      Services::SaveOutage.call(outage)
    end

    original_outage = outage.dup
    outage.start_time -= 23.hours + 30.minutes
    outage.end_time -= 23.hours + 30.minutes
    assert_enqueued_with(job: Jobs::OverdueJob, at: outage.end_time) do
      Services::SaveOutage.call(outage)
    end

    assert Jobs::OverdueJob.send(:job_invalid?,
      original_outage,
      outage,
      @user,
      @user)
  end

  test "outage ends later than originally planned" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 5.minutes)
    assert_enqueued_with at: outage.end_time do
      Services::SaveOutage.call(outage)
    end

    original_outage = outage.dup
    outage.start_time += 23.hours + 30.minutes
    outage.end_time += 23.hours + 30.minutes
    assert_enqueued_with(job: Jobs::OverdueJob, at: outage.end_time) do
      Services::SaveOutage.call(outage)
    end

    assert Jobs::OverdueJob.send(:job_invalid?,
      original_outage,
      outage,
      @user,
      @user)
  end

  test "user stops asking for overdue notifications" do
    outage = make_outage_with_ci_watch
    Services::SaveOutage.call(outage)
    assert_enqueued_jobs 1, only: Jobs::OverdueJob
    original_user = @user.dup
    @user.notify_me_on_overdue_outage = false
    @user.save!

    assert Jobs::OverdueJob.send(:job_invalid?,
      outage,
      outage,
      original_user,
      @user)
  end

  test "user asks for overdue notifications with existing outage" do
    @user.notify_me_on_overdue_outage = false
    Services::SaveUser.call(@user)
    outage = make_outage_with_ci_watch(Time.zone.now.round + 2.hours)
    Services::SaveOutage.call(outage)
    assert_no_enqueued_jobs only: Jobs::OverdueJob
    # puts "@user.outages: #{@user.outages}"
    # puts "@user.cis: #{@user.cis.inspect}"
    # puts "And so on: #{@user.cis.map(&:outages).flatten.inspect}"
    # TODO: Why do I need this reload?
    @user.reload
    # puts "@user.outages: #{@user.outages}"
    # puts "And so on: #{@user.cis.map(&:outages).flatten.inspect}"
    assert_enqueued_with(job: Jobs::OverdueJob, at: outage.end_time) do
      @user.notify_me_on_overdue_outage = true
      assert Services::SaveUser.call(@user)
    end
  end

  test "user stops watching outage" do
    outage = make_outage(Time.zone.now.round + 10.minutes)
    Services::SaveOutage.call(outage)
    watch = outage.watches.create!(user: @user)
    assert_enqueued_jobs 1
    watch.active = false
    watch.save!
    Services::SaveUser.call(@user)
    assert Jobs::OverdueJob.send(:job_invalid?,
      outage,
      outage,
      @user,
      @user)
  end

  test "user stops watching CI of outage" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 10.minutes)
    Services::SaveOutage.call(outage)
    assert_enqueued_jobs 1, only: Jobs::OverdueJob
    @user.watches.each do |w|
      w.active = false
      w.save!
    end
    Services::SaveUser.call(@user)
    assert Jobs::OverdueJob.send(:job_invalid?,
      outage,
      outage,
      @user,
      @user)
  end

  test "outage is completed when overdue job runs" do
    outage = make_outage_with_ci_watch(Time.zone.now.round + 10.minutes)
    Services::SaveOutage.call(outage)
    assert_enqueued_jobs 1, only: Jobs::OverdueJob
    outage.completed = true
    Services::SaveOutage.call(outage)
    assert Jobs::OverdueJob.send(:job_invalid?,
      outage,
      outage,
      @user,
      @user)
  end

  private

  def make_outage(start_time = Time.zone.now.round)
    @account.outages.build(name: "Outage",
                           start_time: start_time,
                           end_time: start_time + 30.minutes,
                           causes_loss_of_service: true,
                           completed: false)
  end

  def make_outage_with_ci_watch(start_time = Time.zone.now.round)
    outage = make_outage(start_time)
    outage.cis_outages.build(ci: @ci)
    outage
  end

  def setup # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # TODO: Create more users.
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
