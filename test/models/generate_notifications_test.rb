require "test_helper"
class GenerateNotificationsTest < ActiveSupport::TestCase
  test "online notification, outage event, outage watched" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    mark_all_existing_events_handled

    # Generate an :outage event
    event = Event.create(handled: false,
                         outage_id: outage.id,
                         text: "A test event",
                         event_type: :outage)

    assert_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 1, notifications.size, "Wrong number of notifications generated"
      notification = notifications.first
      assert_equal "online", notification.notification_type
    end
  end

  test "online notification, outage event, ci watched" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, with a ci and a watch on that ci
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: true,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    mark_all_existing_events_handled

    # Generate an :outage event
    Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)

    assert_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 1, notifications.size,
        "Wrong number of notifications generated"
      notification = notifications.first
      assert_equal "online", notification.notification_type
    end
  end

  test "online notification, outage event, ci parent watched" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
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

    # Generate an :outage event
    Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)

    assert_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 1, notifications.size,
        "Wrong number of notifications generated"
      notification = notifications.first
      assert_equal "online", notification.notification_type
    end
  end

  test "no notification for inactive ci" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, with a ci and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: false,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    mark_all_existing_events_handled

    # Generate an :outage event
    Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)

    assert_no_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 0, notifications.size,
        "Wrong number of notifications generated"
    end
  end

  test "outage notification and make active outage inactive" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    # Generate an :outage event
    event = Event.create(handled: false,
                         outage_id: outage.id,
                         text: "A test event",
                         event_type: :outage)

    assert_equal 1, user.outstanding_online_notifications.size

    assert_difference "Event.count" do
      outage.active = false
      cancelled_event = Services::SaveOutage.call(outage)

      assert_equal "outage", cancelled_event.event_type

      assert_equal "Outage Cancelled", cancelled_event.text
    end

    assert_difference "Notification.count" do
      Services::GenerateNotifications.call
    end
    assert_equal 2, user.outstanding_online_notifications.size

    assert_check_user_outstanding_online_notifications(user)
  end

  test "outage notification and make active ci inactive" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
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

    # Generate an :outage event
    event = Event.create(handled: false,
                         outage_id: outage.id,
                         text: "A test event",
                         event_type: :outage)

    assert_equal 1, user.outstanding_online_notifications.size

    assert_no_difference "Event.count" do
      assert_no_difference "Notification.count" do
        ci.active = false
        ci.save
      end
    end

    assert_equal 1, user.outstanding_online_notifications.size

    assert_check_user_outstanding_online_notifications(user)
  end

  test "inactive outage watch does not generate notifications" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, and an inactive watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: false, user: user, watched: outage)

    mark_all_existing_events_handled

    # Generate an :outage event
    Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)

    assert_no_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 0, notifications.size,
        "Wrong number of notifications generated"
    end
  end

  test "inactive ci watch does not generate notifications" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, with a ci and an inactive watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
                           active: false,
                           description: "Server Test",
                           name: "Server Test")

    watch = ci.watches.create(active: false, user: user)

    mark_all_existing_events_handled

    # Generate an :outage event
    Event.create(handled: false, outage_id: outage.id, text: "A test event", event_type: :outage)

    assert_no_difference "Notification.all.size" do
      Services::GenerateNotifications.call
      notifications = Notification.where(watch_id: watch.id)
      assert_equal 0, notifications.size,
        "Wrong number of notifications generated"
    end
  end

  test "outage notification and make outage watch inactive" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    # Prepare the test by ensuring existing events are handled and existing
    # notifications are notified
    mark_all_existing_events_handled
    mark_all_existing_notifications_notified

    # Generate an :outage event
    event = Event.create(handled: false,
                         outage_id: outage.id,
                         text: "A test event",
                         event_type: :outage)

    assert_equal 1, user.outstanding_online_notifications.size

    # Outstanding notificatins should be 'removed' if watch is inactive
    assert_difference "user.outstanding_online_notifications.size", -1 do
      watch.active = false
      watch.save
    end

    # Outstanding notifications should revive if watch is re-activated
    assert_difference "user.outstanding_online_notifications.size" do
      watch.active = true
      watch.save
    end
  end

  test "outage notification and make ci watch inactive" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notify_me_by_email = false
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

    # Generate an :outage event
    event = Event.create(handled: false,
                         outage_id: outage.id,
                         text: "A test event",
                         event_type: :outage)

    assert_equal 1, user.outstanding_online_notifications.size

    # Outstanding notifications should be 'removed' if watch is inactive
    assert_difference "user.outstanding_online_notifications.size", -1 do
      watch.active = false
      watch.save
    end

    # Outstanding notifications should revive if watch is re-activated
    assert_difference "user.outstanding_online_notifications.size" do
      watch.active = true
      watch.save
    end
  end


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

  def assert_check_user_outstanding_online_notifications(user)
    user.outstanding_online_notifications.each do |n|
      assert n.notification_type
      assert n.watch
      assert n.watch.watched.name
      assert n.event
      assert n.event.outage
    end
  end
end
