module TestCases
  # Simply case 1 user with an outstanding email notification
  # Create Account with 1
  # Users have all watch preferences set to true
  # Users have email set to true, receive daily
  # Create 1 Outage
  # No CIs
  # User has a watch on Outage
  # Event created for outage
  # 1 Email notifications created for user
  def setup_config02(account_name)
    account = Account.create(name: "#{account_name} #{Time.zone.now.strftime("%Y%m%d_%H%M%S%L")}")
    user = User.create(name: "User for #{account_name}",
                       email: "user@#{account_name}.com".delete(" "),
                       password: "password1")

    user.notify_me_before_outage = false
    user.notify_me_on_outage_changes = false
    user.notify_me_on_note_changes = false
    user.notify_me_on_outage_complete = false
    user.notify_me_on_overdue_outage = false
    user.preference_email_time = "11:00"
    user.preference_individual_email_notifications = false
    user.preference_notify_me_by_email = true

    assert user.save

    #  Outages
    outage = Outage.create(account: account,
                           active: true,
                           causes_loss_of_service: true,
                           completed: false,
                           description: "A description of Test Outage A",
                           end_time: Time.find_zone("Samoa").now + 26.hours,
                           name: "#{account_name} Test Outage A",
                           start_time: Time.find_zone("Samoa").now + 24.hours)
    assert outage.save

    #  Events
    event = Event.create(handled: true,
                         outage: outage,
                         text: "Test Event on #{outage.name}",
                         event_type: :outage)
    assert event.save

    # Watches
    watch = Watch.create(active: true, user: user, watched:outage)
    assert watch

    # Notifications
    notification = Notification.create(event: event,
                                       watch: watch,
                                       notified: false,
                                       notification_type: :email)

    #  Return the user
    user
  end
end
