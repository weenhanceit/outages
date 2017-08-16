require "test_helper"

class EmailJobTest < ActiveJob::TestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "user asks for batch e-mail notifications" do
    @user.preference_individual_email_notifications = true
    @user.save!
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        assert_enqueued_with(job: Jobs::EmailJob,
                             at: Time.zone.local(2017, 07, 29, 8)) do
          @user.preference_individual_email_notifications = false
          assert Services::SaveUser.call(@user)
        end
      end
    end
  end

  test "job actually runs" do
    @user.preference_individual_email_notifications = true
    @user.save!
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        perform_enqueued_jobs(only: Jobs::EmailJob) do
          @user.preference_individual_email_notifications = false
          assert Services::SaveUser.call(@user)
        end
        assert_performed_jobs 1
      end
    end
  end

  test "change batch e-mail time earlier" do
    original_user = @user.dup
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        assert_enqueued_with(job: Jobs::EmailJob,
                             at: Time.zone.local(2017, 07, 29, 7)) do
          @user.preference_email_time = "7:00"
          assert Services::SaveUser.call(@user)
        end

        assert Jobs::EmailJob.job_invalid?(original_user, @user)
      end
    end
  end

  test "change batch e-mail time later" do
    original_user = @user.dup
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        assert_enqueued_with(job: Jobs::EmailJob,
                             at: Time.zone.local(2017, 07, 28, 11)) do
          @user.preference_email_time = "11:00"
          assert Services::SaveUser.call(@user)
        end

        assert Jobs::EmailJob.job_invalid?(original_user, @user)
      end
    end
  end

  test "user stops e-mail notifications" do
    original_user = @user.dup
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        assert_no_enqueued_jobs(only: Jobs::EmailJob) do
          @user.preference_notify_me_by_email = false
          assert Services::SaveUser.call(@user)
        end

        assert Jobs::EmailJob.job_invalid?(original_user, @user)
      end
    end
  end

  test "user stops batch e-mail notifications" do
    original_user = @user.dup
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 9) do
        assert_no_enqueued_jobs(only: Jobs::EmailJob) do
          @user.preference_individual_email_notifications = true
          assert Services::SaveUser.call(@user)
        end

        assert Jobs::EmailJob.job_invalid?(original_user, @user)
      end
    end
  end

  # test "outage is completed when overdue job runs" do
  #   outage = make_outage_with_ci_watch(Time.zone.now.round + 10.minutes)
  #   Services::SaveOutage.call(outage)
  #   assert_enqueued_jobs 1, only: Jobs::EmailJob
  #   outage.completed = true
  #   Services::SaveOutage.call(outage)
  #   assert Jobs::EmailJob.job_invalid?(
  #     outage,
  #     outage,
  #     @user,
  #     @user)
  # end

  private

  # def make_outage(start_time = Time.zone.now.round)
  #   @account.outages.build(name: "Outage",
  #                          start_time: start_time,
  #                          end_time: start_time + 30.minutes,
  #                          causes_loss_of_service: true,
  #                          completed: false)
  # end

  # def make_outage_with_ci_watch(start_time = Time.zone.now.round)
  #   outage = make_outage(start_time)
  #   outage.cis_outages.build(ci: @ci)
  #   outage
  # end

  def setup # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
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
      # @ci = @account.cis.create!(name: "CI")
      # @user.watches.create!(watched: @ci)
    end
  end
end
