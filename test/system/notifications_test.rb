require "application_system_test_case"
require "test_helper"

class NotificationsTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  include ActiveJob::TestHelper

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

    expected = { outage: outage_name, text: "New Outage" }
    assert_check_notifications expected

    # Check that notifications and events are unchanged if we re-visit pages
    assert_no_difference "Event.count" do
      assert_no_difference "Notification.count" do
        visit cis_path
        assert_check_notifications expected

        visit month_outages_path
        assert_check_notifications expected

        visit week_outages_path
        assert_check_notifications expected

        visit fourday_outages_path
        assert_check_notifications expected

        visit day_outages_path
        assert_check_notifications expected

      end
    end
  end

  test "notification generated for edit outage on watched outage" do
    # Set up the user and outage name to be used in this test
    # Set notified to be true on all outstanding online notifications
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    user.notify_me_on_outage_changes = true
    user.notify_me_before_outage = true
    user.notify_me_on_outage_complete = true
    user.notify_me_on_overdue_outage = true
    user.notification_periods_before_outage = 4
    user.notification_period_interval = "hours"

    user.save!

    mark_all_existing_notifications_notified
    user.reload

    # Pick an outage, any outage and create a watch on it
    outage = Outage.where(account: user.account, name: "Outage A").first
    outage.watches.create(active: true, user: user)
    # assert_no_enqueued_jobs

    # Edit the outage and check that 1 event and no new outages or watches
    # were generated
    # puts "notifications_test.rb TP_#{__LINE__}: Outage: #{outage.inspect}"
    visit edit_outage_url(outage.id)
    # puts "notifications_test.rb TP_#{__LINE__}:"
    # assert_no_enqueued_jobs

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
    expected = { outage: outage.name, text: "Outage Changed" }
    assert_check_notifications expected
    # assert_no_enqueued_jobs

    # Check that notifications and events are unchanged if we re-visit pages
    perform_enqueued_jobs do
      assert_no_difference "Event.count" do
        assert_no_difference "Notification.count" do

          # now go back to the day of our outage
          # puts outage.inspect
          goto = outage.end_time.strftime("%Y-%m-%d")
          # puts "#{__LINE__}: #{goto}"
          fill_in "Outages After", with: goto
          click_on "Refresh"
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          # FIXME: Problem seems to be related to the call back within outages
          # after_add: :schedule_reminders
          # It appears that 'extra' notifications are generated on outages
          # that are not being watched.

          visit cis_path
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          visit month_outages_path
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          visit week_outages_path
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          visit fourday_outages_path
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          visit day_outages_path
          # puts "--#{__LINE__}--"
          assert_check_notifications expected

          # assert false
          # sleep 5
          # take_screenshot
          # assert_no_enqueued_jobs
          # puts "--#{__LINE__}--"
          # assert_check_notifications expected
        end
      end
    end


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
    assert_check_notifications
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

  # TODO: This test, and the next test, simulate the use of an active job to
  # create notifications for overdue and reminders.  There is a time element
  # and we should review whether these tests should incorporate time travel to
  # ensure that jobs operate as expected with different timing.


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

      assert_enqueued_jobs 0

      # Pick an outage, any outage and create a watch on it
      outage = Outage.where(account: user.account).first
      # TODO: The fixture selected likely has an end date in the past.  We need
      # to review what should happen should the user save an outage with a date
      # in the past.  It is suggested that we may wnat to make this a validation
      # for saving of outages.

      perform_enqueued_jobs do
        # Expect 2 events - the outage change and the overdue event
        assert_difference "Event.count", 2 do
          assert_difference "Notification.count" do
            outage.watches.create(active: true, user: user)
            outage.end_time = outage.end_time + 1.minute
            Services::SaveOutage.call(outage)

            assert_equal 1,
              Event.where(outage: outage, event_type: :outage).size

            assert_equal 1,
              Event.where(outage: outage, event_type: :overdue).size

            assert_enqueued_jobs 0

            user = sign_in_for_system_tests(users(:edit_ci_outages))

            expected = { outage: outage.name,
                         text: "Outage Not Completed As Scheduled" }
            assert_check_notifications expected
          end
        end
      end
      assert_enqueued_jobs 0
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

      assert_enqueued_jobs 0

      # Pick an outage, any outage and create a watch on it
      outage = Outage.where(account: user.account).first

      perform_enqueued_jobs do
        # Expect 2 events - the outage change and the reminder event
        assert_difference "Event.count", 2 do
          assert_difference "Notification.count" do
            outage.watches.create(active: true, user: user)
            outage.end_time = outage.end_time + 1.minute
            Services::SaveOutage.call(outage)

            assert_equal 1,
              Event.where(outage: outage, event_type: :outage).size,
              "Should Be 1 :outage event from saved changes"

            assert_equal 1,
              Event.where(outage: outage, event_type: :reminder).size,
              "Should Be 1 :reminder event"
            assert_enqueued_jobs 0

            user = sign_in_for_system_tests(users(:edit_ci_outages))

            expected = { outage: outage.name,
                         text: "Outaged Scheduled to Begin at " \
                         "#{outage.start_time.to_s(:iso8601)}" }
            assert_check_notifications expected
          end
        end
      end
      assert_enqueued_jobs 0

      # TODO: This test needs to be fixed for the "Job" approach to reminders.
      # LCR moved the assert_difference up here to catch the fact that the
      # reminder can get generated simply by adding the watch. But if we add
      # the check to not generate the notification if the event is passed,
      # we'll have to create a specific event, or time travel to the right time
      # earlier.
      # Because the generation of the notification now depends on the job,
      # this whole testing approach has to be changed to force the job to
      # run.
      # assert_difference "Event.count" do
      #   assert_difference "Notification.count" do
      #     # Pick an outage, any outage and create a watch on it
      #     outage = Outage.where(account: user.account).first
      #     outage.watches.create(active: true, user: user)
      #
      #     # Be sure that time travelling will only pick up an event and notification
      #     # for the outage we are watching in this test
      #     mark_all_but_selected_outage_complete(outage.id)
      #     puts "----------------------------------#{__LINE__}-----------------------------"
      #
      #     # TODO: The next comment doesn't seem to match the code.
      #     # Time travel past the end date of the outage
      #     travel_to outage.start_time - 1.minute do
      #       puts "----------------------------------#{__LINE__}-----------------------------"
      #       user = sign_in_for_system_tests(users(:edit_ci_outages))
      #       # After login we should be on the Outage index page
      #       # There should be 1 notification and the outage name show be there
      #       puts "----------------------------------#{__LINE__}-----------------------------"
      #       assert_check_notifications [outage.name]
      #       puts "----------------------------------#{__LINE__}-----------------------------"
      #       assert false
      #     end
      #   end
      # end
    end
  end

  test "notification generated for notes on watched outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
    end
    sleep_period = 1
    mark_all_existing_notifications_notified
    note_text = "This is text for a note"

    user = users(:edit_ci_outages)
    user.notify_me_before_outage = false
    user.notify_me_on_outage_changes = false
    user.notify_me_on_note_changes = true
    user.notify_me_on_outage_complete = false
    user.notify_me_on_overdue_outage = false
    user.save!

    user = sign_in_for_system_tests(users(:edit_ci_outages))
    assert_enqueued_jobs 0

    # Grab an outage from the fixtures that this user is watching
    outage = user.watches.where(watched_type: "Outage").first.watched
    assert outage.is_a?(Outage)
    visit outage_path(outage.id)
    # wh = save_screenshot "tmp/screenshots/debug_shot.png"
    # puts "----------- [#{wh}] -----------"
    assert_current_path outage_path(outage.id)

    # There should be no notifications viewed
    expected = []
    assert_check_notifications expected

    #  Notification for a new note
    fill_in "New Note", with: note_text
    click_button "Save Note"
    visit outages_path
    # save_screenshot "tmp/screenshots/x_debug_shot.png"
    #  Check that we have a notification
    expected = { outage: outage.name, text: "Note Added" }
    # NOTE: Tests can fail because of timing.
    assert_check_notifications expected

    mark_all_existing_notifications_notified

    #  Notification for a modified note
    visit outage_path(outage.id)
    assert_current_path outage_path(outage.id)

    note = outage.notes.where(note: note_text).first
    class_of_interest = ".note-#{note.id}"
    # puts "CLASS: #{class_of_interest}"
    within(class_of_interest) do
      assert_text note_text
      click_link "Edit"
      sleep sleep_period
      # save_screenshot "tmp/screenshots/x_debug_shot.png"
    end
    note_text = "#{note_text} -- changed"
    fill_in "Edit Note", with: note_text
    click_button "Update Note"
    sleep sleep_period

    #  Check that we now have 1 notification for modified note
    visit outages_path
    expected = { outage: outage.name, text: "Note Modified" }
    assert_check_notifications expected

    mark_all_existing_notifications_notified

    #  Notification for a deleted note
    visit outage_path(outage.id)
    assert_current_path outage_path(outage.id)

    note = outage.notes.where(note: note_text).first
    class_of_interest = ".note-#{note.id}"
    # puts "CLASS: #{class_of_interest}"
    # save_screenshot "tmp/screenshots/x_debug_shot.png"
    within(class_of_interest) do
      assert_text note_text
      accept_confirm("Are you sure you want to delete this note?") do
        click_link "Delete"
      end
      # sleep sleep_period
      # save_screenshot "tmp/screenshots/x_debug_shot.png"
    end

    # save_screenshot "tmp/screenshots/x_debug_shot.png"
    #  Check that we have a notification
    visit outages_path
    expected = { outage: outage.name, text: "Note Deleted" }
    assert_check_notifications expected
  end

  private

  def assert_check_notifications(expected = [])
    expected = [expected] unless expected.is_a?(Array)
    num = expected.size
    within(".notifications") do
      assert_selector "h3", text: "Notifications"

      content = "You have #{num} un-read #{'notification'.pluralize(num)}."
      assert_text content

      expected.each do |e|
        assert e.is_a?(Hash), "Test Code Error, pass an array of hashes"
        assert_not e.blank?, "Test Code Error, name cannot be blank"
        # assert_content e
        outage_element = find("a", text: e[:outage])
        grandparent_element = outage_element.find(:xpath, "..").find(:xpath, "..")
        text_element = grandparent_element.find(".notification-text")

        assert_equal e[:text], text_element.text
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
