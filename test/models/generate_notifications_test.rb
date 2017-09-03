require "test_helper"
class GenerateNotificationsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "notifications for outage event, outage watched" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    mark_all_existing_events_handled

    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 2 do
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :outage,
            "A test event")

          assert_check_notifications(%i[online email],
            watch, "outage", outage)

        end
      end
    end
  end

  test "notifications for outage event, outage watched by two users" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user1 = users(:basic)
    user1.notify_me_on_outage_changes = true
    user1.preference_notify_me_by_email = true
    user1.save

    user2 = users(:edit_ci_outages)
    user2.notify_me_on_outage_changes = true
    user2.preference_notify_me_by_email = true
    user2.save



    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user2.account_id))
    watch1 = Watch.create(active: true, user: user1, watched: outage)
    watch2 = Watch.create(active: true, user: user2, watched: outage)

    mark_all_existing_events_handled

    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 4 do
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :outage,
            "A test event")

          assert_check_notifications(%i[online email],
            watch1, "outage", outage)

          assert_check_notifications(%i[online email],
            watch2, "outage", outage)

        end
      end
    end
  end

  test "notifications for completed event, outage watched" do
    # Prepare a user who wants outage complete notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = false
    user.notify_me_on_outage_complete = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    mark_all_existing_events_handled
    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 2 do
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :completed,
            "A test event - completed")

          assert_check_notifications(%i[online email],
            watch, "completed", outage)

        end
      end
    end
  end

  test "online notification, outage event, ci watched" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, with a ci and a watch on that ci
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    mark_all_existing_events_handled

    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 2 do
          # Generate the event and notifications
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :outage,
            "A test event")

          assert_check_notifications(%i[online email],
            watch, "outage", outage)
        end
      end
    end
  end

  test "online notification, outage event, ci parent watched" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    # Create a ci and associate it with the outage
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test C",
                           name: "Server Test Child")

    # Create a parent for the ci, that will actually be watched by the user
    ci_parent = Ci.create(account_id: user.account_id,
                          active: true,
                          description: "Server Test P",
                          name: "Server Test Parent")

    watch = ci_parent.watches.create(active: true, user: user)

    ci.parent_links.create(parent: ci_parent)

    mark_all_existing_events_handled

    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 2 do
          # Generate the event and notifications
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :outage,
            "A test event")

          assert_check_notifications(%i[online email],
            watch, "outage", outage)
        end
      end
    end
  end

  test "only 1 online generated, outage, ci and ci parent watched" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    # Create a ci and associate it with the outage
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test C",
                           name: "Server Test Child")

    # Create a parent for the ci, that will actually be watched by the user
    ci_parent = Ci.create(account_id: user.account_id,
                          active: true,
                          description: "Server Test P",
                          name: "Server Test Parent")

    _watch_indirect = ci_parent.watches.create(active: true, user: user)
    _watch_direct_thru_service = ci.watches.create(active: true, user: user)
    watch_direct = outage.watches.create(active: true, user: user)

    ci.parent_links.create(parent: ci_parent)

    mark_all_existing_events_handled

    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 2 do
        # Generate the event and notifications
        Services::GenerateNotifications.create_event_and_notifications(outage,
          :outage,
          "A test event")

        assert_check_notifications(%i[online email],
          watch_direct, "outage", outage)
        end
      end
    end
  end

  test "no notification for inactive ci" do
    # Prepare a user who wants outage change notifications,
    # online and email
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    mark_all_existing_notifications_notified


    # Create an outage, with a ci and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: false,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    mark_all_existing_events_handled
    assert_enqueued_jobs 0 do
      assert_difference "Event.all.size" do
        assert_difference "Notification.all.size", 0 do
          # Generate the event and notifications
          Services::GenerateNotifications.create_event_and_notifications(outage,
            :outage,
            "A test event")

          assert_no_notifications(%i[online email], watch)
        end
      end
    end

    # TODO: Review the reload of outage to make sure Phil understands and has
    # analyzed this correctly
    # # # Generate an :outage event
    #  ev = Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)
    # # outage.save!
    # outage.reload
    # ev.reload
    # puts "test #{__LINE__} Unique watches: (#{outage.id}) #{outage.watches_unique_by_user.inspect}"
    # puts "test #{__LINE__} Unique watches: (#{ev.outage.id})  #{ev.outage.watches_unique_by_user.inspect}"
    #
    # assert_no_difference "Notification.all.size" do
    #   Services::GenerateNotifications.call
    #   notifications = Notification.where(watch_id: watch.id)
    #   assert_equal 0, notifications.size,
    #     "Wrong number of notifications generated"
    # end
  end

  test "outage notification and make active outage inactive" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    assert_difference "Notification.count", 2 do
      assert_difference "Event.count" do
        outage.active = false
        events = Services::SaveOutage.call(outage)

        assert_equal 1, events.size, "Should only see an outage event on cancel"
        cancelled_event = events[0]
        assert_equal "outage", cancelled_event.event_type

        assert_equal "Outage Cancelled", cancelled_event.text
      end
    end

    assert_check_notifications(%i[online email],
      watch, "outage", outage)

    assert_equal 1, user.outstanding_notifications(:online).size
  end

  # TODO: is this the behaviour we want?  Making ci inactive does not impact
  # notifications
  test "outage notification and make active ci inactive" do
    # Prepare a user who wants outage change notifications,
    # online and email
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, with a ci and a watch on that ci
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    Services::GenerateNotifications.create_event_and_notifications(outage,
      :outage,
      "A test event")

    assert_equal 1, user.outstanding_notifications(:online).size

    assert_check_notifications(%i[online email], watch, "outage", outage)

    assert_no_difference "Event.count" do
      assert_no_difference "Notification.count" do
        ci.active = false
        ci.save
      end
    end

    assert_equal 1, user.outstanding_notifications(:online).size

    assert_check_notifications(%i[online email], watch, "outage", outage)
  end

  test "inactive outage watch does not generate notifications" do
    # Prepare a user who wants outage change notifications,
    # online and email
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, and an inactive watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: false, user: user, watched: outage)

    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    assert_no_difference "Notification.all.size" do
      Services::GenerateNotifications.create_event_and_notifications(outage,
        :outage,
        "A test event")

      assert_no_notifications(%i[online email], watch)
    end
  end

  test "inactive ci watch does not generate notifications" do
    # Prepare a user who wants outage change notifications,
    # online and email
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, with a ci and an inactive watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: false,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: false, user: user)

    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    assert_no_difference "Notification.all.size" do
      Services::GenerateNotifications.create_event_and_notifications(outage,
        :outage,
        "A test event")

      assert_no_notifications(%i[online email], watch)
    end
  end

  test "outage notification and make outage watch inactive" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    Services::GenerateNotifications.create_event_and_notifications(outage,
      :outage,
      "A test event")

    assert_equal 1, user.outstanding_notifications(:online).size
    assert_check_notifications(%i[online email], watch, "outage", outage)

    # Outstanding notificatins should be 'removed' if watch is inactive
    assert_difference "user.outstanding_notifications(:online).size", -1 do
      watch.active = false
      watch.save

      assert_no_notifications(%i[online email], watch)
    end

    # Outstanding notifications should revive if watch is re-activated
    assert_difference "user.outstanding_notifications(:online).size" do
      watch.active = true
      watch.save

      assert_equal 1, user.outstanding_notifications(:online).size
      assert_check_notifications(%i[online email], watch, "outage", outage)
    end
  end

  test "outage notification and make ci watch inactive" do
    # Prepare a user who wants outage change notifications,
    # online and email (Should generate 2 notifications)
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = true
    user.save

    # Create an outage, with a ci and a watch on that ci
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    Services::GenerateNotifications.create_event_and_notifications(outage,
      :outage,
      "A test event")

    assert_equal 1, user.outstanding_notifications(:online).size
    assert_check_notifications(%i[online email], watch, "outage", outage)

    # Outstanding notifications should be 'removed' if watch is inactive
    assert_difference "user.outstanding_notifications(:online).size", -1 do
      watch.active = false
      watch.save

      assert_no_notifications(%i[online email], watch)
    end

    # Outstanding notifications should revive if watch is re-activated
    assert_difference "user.outstanding_notifications(:online).size" do
      watch.active = true
      watch.save

      assert_equal 1, user.outstanding_notifications(:online).size
      assert_check_notifications(%i[online email], watch, "outage", outage)
    end
  end

  # -------------------------------------------------------------------------
  # TODO: Review these tests.  These are assoicated with reminders and overdue
  #         and perhaps should be tested elsewhere (this is testing
  #         generation of notifications)
  # Test removed 18 aug 2017. review that this is tested elsewhere - pmc
  #
  # test "online notification, outage event, outage watched, overdue" do
  #   # Prepare a user who wants outage complete notifications,
  #   # online only
  #   user = users(:basic)
  #   user.notify_me_before_outage = false
  #   user.notify_me_on_outage_changes = false
  #   user.notify_me_on_outage_complete = false
  #   user.notify_me_on_overdue_outage = true
  #   user.preference_notify_me_by_email = false
  #   user.save
  #
  #   # Create an outage, and a watch on that outage
  #   outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
  #   watch = Watch.create(active: true, user: user, watched: outage)
  #
  #   mark_all_existing_events_handled
  #
  #   # Generate an :outage event
  #   event = Event.create(handled: false,
  #                        outage_id: outage.id,
  #                        text: "A test event - overdue",
  #                        event_type: :overdue)
  #
  #   assert_difference "Notification.all.size" do
  #     Services::GenerateNotifications.call
  #     notifications = Notification.where(watch_id: watch.id)
  #     assert_equal 1, notifications.size, "Wrong number of notifications generated"
  #     notification = notifications.first
  #     assert_equal "online", notification.notification_type
  #     assert_equal "overdue", notification.event.event_type
  #   end
  # end
  #
  # test "no online notification, outage event, outage watched, overdue, outage complete" do
  #   # Prepare a user who wants outage complete notifications,
  #   # online only
  #   user = users(:basic)
  #   user.notify_me_before_outage = false
  #   user.notify_me_on_outage_changes = false
  #   user.notify_me_on_outage_complete = false
  #   user.notify_me_on_overdue_outage = true
  #   user.preference_notify_me_by_email = false
  #   user.save
  #
  #   # Create an outage, and a watch on that outage
  #   outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
  #   watch = Watch.create(active: true, user: user, watched: outage)
  #
  #   mark_all_existing_events_handled
  #
  #   # Generate an :outage event
  #   event = Event.create(handled: false,
  #                        outage_id: outage.id,
  #                        text: "A test event - overdue",
  #                        event_type: :overdue)
  #
  #   outage.completed = true
  #   outage.save
  #
  #   assert_no_difference "Notification.all.size" do
  #     Services::GenerateNotifications.call
  #     notifications = Notification.where(watch_id: watch.id)
  #
  #     assert_equal 0, notifications.size, "Wrong number of notifications generated"
  #   end
  # end
  #
  # test "online notification, outage event, outage watched, reminder" do
  #   # Prepare a user who wants outage complete notifications,
  #   # online only
  #   user = users(:basic)
  #   user.notify_me_before_outage = true
  #   user.notify_me_on_outage_changes = false
  #   user.notify_me_on_outage_complete = false
  #   user.notify_me_on_overdue_outage = false
  #   user.preference_notify_me_by_email = false
  #   user.save
  #
  #   # Create an outage, and a watch on that outage
  #   outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
  #   watch = Watch.create(active: true, user: user, watched: outage)
  #
  #   mark_all_existing_events_handled
  #
  #   # Generate an :outage event
  #   event = Event.create(handled: false,
  #                        outage_id: outage.id,
  #                        text: "A test event - reminder",
  #                        event_type: :reminder)
  #
  #   assert_difference "Notification.all.size" do
  #     Services::GenerateNotifications.call
  #     notifications = Notification.where(watch_id: watch.id)
  #     assert_equal 1, notifications.size, "Wrong number of notifications generated"
  #     notification = notifications.first
  #     assert_equal "online", notification.notification_type
  #     assert_equal "reminder", notification.event.event_type
  #   end
  # end
#-------------------------------------------------------------------------------

  private

  def mark_all_existing_events_handled
    Event.all.each do |e|
      e.handled = true
      e.save
    end
  end

  def mark_all_existing_notifications_notified
    Notification.all.each do |n|
      n.notified = true
      n.save
    end
  end

  def test_outage_defaults
    {
      account: accounts(:company_a),
      active: true,
      causes_loss_of_service: true,
      completed: false,
      description: "A test outage",
      end_time: Time.find_zone("Samoa").now + 26.hours,
      name: "Test Outage",
      start_time: Time.find_zone("Samoa").now + 24.hours
    }
  end

  def assert_check_notifications(notification_types, watch, event_type, outage)
    notification_types = [notification_types] unless outages.is_a?(Array)
    notification_types.each do |t|
      notifications = Notification.where(watch: watch,
                                         notification_type: t)
      assert_equal 1, notifications.size,
        "Expected 1 #{t} notification to be generated for this watch"

      notification = notifications.first
      assert_notification notification, watch, event_type, outage
    end

    assert_equal 0, Event.where(handled: false).size, "Unhandled Events"
  end

  def assert_no_notifications(notification_types, watch)
    notification_types = [notification_types] unless outages.is_a?(Array)
    notification_types.each do |t|
      assert_equal 0, watch.user.outstanding_notifications(t).size,
        "Expected 0 #{t} notification to be generated for this watch"
    end
    assert_equal 0, Event.where(handled: false).size,
      "All events should be handled"
  end

  def assert_notification(notification, watch, event_type, outage)
    assert_equal event_type, notification.event.event_type
    assert_equal watch, notification.watch
    assert_equal outage, notification.event.outage
  end
end
