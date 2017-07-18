require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "notification generated for new outage on watched ci" do
    # Set up the user and outage name to be used in this test
    # Set notified to be true on all outstanding online notifications
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    user.notify_me_on_outage_changes = true
    user.save!
    outage_name = "Our Test Outage"
    mark_all_existing_notifications_notified
    user.reload

    # Create a watch on a Ci,.
    # TODO This should be done using the actual steps a user would follow
    # This shortcut is in place until the functionality is implemented
    ci = cis(:company_a_ci_a)
    # puts "notifications_test.rb #{__LINE__}: ci: #{ci.name}"
    ci.watches.create(active: true, user: user)

    # Create and outage and assign our ci to it
    visit new_outage_url

    assert_difference "Event.count" do
      assert_difference "Outage.where(account: user.account).size" do
        assert_no_difference "Watch.count" do
          fill_in "Name", with: outage_name
          fill_in "Description",
            with: "Outage to generate online notification"
          # click_on "Save"
          click_list_item ci.name
          click_on "<"
          assert_difference "CisOutage.count" do
            click_on "Save"
          end
        end
      end
    end

    # After save we should be on the Outage index page
    # There should be a single notification and the outage name show be listed
    assert_selector ".test-home-page"
    assert_check_notifications [outage_name]
  end

  test "notification generated for edit outage on watched outage" do
    # Set up the user and outage name to be used in this test
    # Set notified to be true on all outstanding online notifications
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    user.notify_me_on_outage_changes = true
    user.save!
    mark_all_existing_notifications_notified
    user.reload

    # Pick an outage, any outage and create a watch on it
    outage = Outage.where(account: user.account).first
    outage.watches.create(active: true, user: user)

    # Edit the outage and check that 1 event and no new outages or watches
    # were generated
    # puts "notifications_test.rb TP_#{__LINE__}: Outage: #{outage.inspect}"
    visit edit_outage_url(outage.id)
    # puts "notifications_test.rb TP_#{__LINE__}:"

    assert_difference "Event.count" do
      assert_no_difference "Outage.where(account: user.account).size" do
        assert_no_difference "Watch.count" do
          fill_in "Description",
            with: "#{outage.description} -- changed"
          click_on "Save"
        end
      end
    end
    # After save we should be on the Outage index page
    # There should be a single notification and the outage name show be listed
    assert_check_notifications [outage.name]
  end

  test "mark a notification read" do
    user = sign_in_for_system_tests(users(:basic))

    within ".notifications" do
      assert_difference "user.notifications.unread.size", -1 do
        assert_text "Outage A", count: 1
        assert_unchecked_field "Read"
        check "Read"
        assert_text "Outage A", count: 1
        sleep 2
        assert_checked_field "Read"
      end
    end

    visit cis_path
    assert_check_notifications []
  end

  test "mark a notification read then mark it unread" do
    user = sign_in_for_system_tests(users(:basic))

    within ".notifications" do
      assert_difference "user.notifications.unread.size", -1 do
        assert_text "Outage A", count: 1
        assert_unchecked_field "Read"
        check "Read"
        assert_text "Outage A", count: 1
        sleep 2
        assert_checked_field "Read"
      end
      assert_difference "user.notifications.unread.size" do
        uncheck "Read"
        assert_text "Outage A", count: 1
        sleep 2
        assert_unchecked_field "Read"
      end
    end
  end

  test "notification generated for overdue outage on watched outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set notified to be true on all outstanding online notifications
      # Set up the user and outage name to be used in this test
      mark_all_existing_notifications_notified

      user = users(:edit_ci_outages)
      user.notify_me_before_outage = false
      user.notify_me_on_outage_changes = false
      user.notify_me_on_note_changes = false
      user.notify_me_on_outage_complete = false
      user.notify_me_on_overdue_outage = true
      user.save!

      # Pick an outage, any outage and create a watch on it
      outage = Outage.where(account: user.account).first
      outage.watches.create(active: true, user: user)

      # sql = "SELECT now() as time_now, end_time, updated_at FROM outages WHERE id = #{outage.id}"
      # conn = ActiveRecord::Base.connection
      # res = conn.execute(sql)
      # msg = "#{__LINE__} Results: Now: #{Time.zone.now} Db Now: #{res[0]['time_now']}  End (db): #{res[0]['end_time']} End Rails: #{outage.end_time}"
      # puts msg

      # Be sure that time travelling will only pick up an event and notification
      # for the outage we are watching in this test
      mark_all_but_selected_outage_complete(outage.id)

      # Time travel past the end date of the outage
      travel_to outage.end_time + 1.second do
        assert_difference "Event.count" do
          assert_difference "Notification.count" do
            user = sign_in_for_system_tests(users(:edit_ci_outages))
            # After login we should be on the Outage index page
            # There should be 1 notification and the outage name show be there
            assert_check_notifications [outage.name]
          end
        end
      end
    end
  end

  test "notification generated for reminder on watched outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set notified to be true on all outstanding online notifications
      # Set up the user and outage name to be used in this test
      mark_all_existing_notifications_notified

      user = users(:edit_ci_outages)
      user.notify_me_before_outage = true
      user.notify_me_on_outage_changes = false
      user.notify_me_on_note_changes = false
      user.notify_me_on_outage_complete = false
      user.notify_me_on_overdue_outage = false
      user.save!

      # Pick an outage, any outage and create a watch on it
      outage = Outage.where(account: user.account).first
      outage.watches.create(active: true, user: user)

      # Be sure that time travelling will only pick up an event and notification
      # for the outage we are watching in this test
      mark_all_but_selected_outage_complete(outage.id)

      # Time travel past the end date of the outage
      travel_to outage.start_time - 1.minute do
        assert_difference "Event.count" do
          assert_difference "Notification.count" do
            user = sign_in_for_system_tests(users(:edit_ci_outages))
            # After login we should be on the Outage index page
            # There should be 1 notification and the outage name show be there
            assert_check_notifications [outage.name]

          end
        end
      end
    end
  end

  private

  def assert_check_notifications(expected = [])
    num = expected.size
    within(".notifications") do
      assert_selector "h2", text: "Notifications"

      content = "You have #{num} un-read #{'notification'.pluralize(num)}."
      assert_content content

      expected.each do |e|
        assert_not e.blank?, "Test Code Error, name cannot be blank"
        assert_content e
      end
    end
  end

  def mark_all_but_selected_outage_complete(outage_id)
    Outage.all.each do |o|
      o.completed = true unless o.id == outage_id
      o.save
    end
  end

  def mark_all_existing_notifications_notified
    Notification.all.each do |n|
      n.notified = true
      n.save
    end
  end
end
