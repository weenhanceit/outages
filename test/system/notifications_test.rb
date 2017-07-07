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
    assert_not Outage.where(name: outage_name).empty?
    assert_selector "h2", text: "Notifications"
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
    assert_selector ".test-home-page"
    assert_selector "h2", text: "Notifications"
    assert_not Outage.where(name: outage.name).empty?

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
    assert_no_selector ".notifications"
    # within ".notifications" do
    #   assert_no_text "Outage A"
    # end
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

  private

  def mark_all_existing_notifications_notified
    Notification.all.each do |n|
      n.notified = true
      n.save
    end
  end

end
