require "test_helper"
class GenerateNotificationsTest < ActiveSupport::TestCase
  test "online notification, outage event, outage watched" do
    # Prepare a user who wants outage change notifications,
    # online only
    user = users(:basic)
    user.notify_me_on_outage_changes = true
    user.preference_notifiy_me_by_email = false
    user.save

    # Create an outage, and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    watch = Watch.create(active: true, user: user, watched: outage)

    # Make sure that all existing events are handled
    prep_test

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
    user.preference_notifiy_me_by_email = false
    user.save

    # Create an outage, with a ci and a watch on that outage
    outage = Outage.create(test_outage_defaults.merge(account_id: user.account_id))
    ci = outage.cis.create(account_id: user.account_id,
      active: true,
      description: "Server Test",
      name: "Server Test")

    watch = ci.watches.create(active: true, user: user)

    # Make sure that all existing events are handled
    prep_test

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
    user.preference_notifiy_me_by_email = false
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

    # Make sure that all existing events are handled
    prep_test

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

  private

  def prep_test
    # -- Mark all events as handled
    Event.all.each do |e|
      e.handled = true
      e.save
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
end
