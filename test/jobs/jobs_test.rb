require "test_helper"

class JobsTest < ActiveJob::TestCase
  class TestJob < ApplicationJob
    def perform(user)
      puts "THE JOB"
      user_now = User.find(user.id)
      puts "ORIGINAL: #{user.notification_periods_before_outage}"
      puts "ORIGINAL: #{user.object_id}"
      puts "CURRENT: #{user_now.notification_periods_before_outage}"
      puts "CURRENT: #{user_now.object_id}"
      puts "They're different" if user.notification_periods_before_outage != user_now.notification_periods_before_outage
    end
  end

  test "old object is different than new" do
    old_user = users(:basic)
    puts "ORIGINAL ORIGINAL: #{old_user.notification_periods_before_outage}"
    puts "ORIGINAL ORIGINAL: #{old_user.object_id}"
    changed_user = old_user.clone
    changed_user.notification_periods_before_outage = 1000
    # changed_user.save!
    puts "ORIGINAL BEFORE PERFORM: #{old_user.notification_periods_before_outage}"
    puts "ORIGINAL BEFORE PERFORM: #{old_user.object_id}"
    puts "CHANGED: #{changed_user.notification_periods_before_outage}"
    puts "CHANGED: #{changed_user.object_id}"
    # assert_output "They're different" do
    TestJob.perform_now(changed_user)
    t = Time.zone.now + 1.second
    # TestJob.set(wait_until: t).perform_later(old_user)
    # travel_to t
    sleep 2
    # end
  end
end
