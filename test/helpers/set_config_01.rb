module TestCases
  # Create Account with 1 main user plus one extra user
  # Users have all watch preferences set to true
  # Users have email set to true, receive daily
  # Create 2 Outages
  # No CIs
  # Both Users have a watch on both Outages
  # 1 Event created for each outage
  # NO Email notifications created for main user, 1 notification created for
  # extra user
  def setup_config01(account_name)
    account = Account.create(name: "#{account_name} #{Time.zone.now.strftime("%Y%m%d_%H%M%S%L")}")
    user_main = User.create(name: "Main User for #{account_name}",
                            email: "main@#{account_name}.com".delete(" "),
                            password: "password1")
    set_all_email(user_main)
    assert user_main.save

    user_extra = User.create(name: "Extra User for #{account_name}",
                             email: "extra@#{account_name}.com".delete(" "),
                             password: "password1")
    set_all_email(user_extra)
    assert user_extra.save

    #  Events
    outage1 = Outage.create(account: account,
                            active: true,
                            causes_loss_of_service: true,
                            completed: false,
                            description: "A description of Test Outage A",
                            end_time: Time.find_zone("Samoa").now + 26.hours,
                            name: "#{account_name} Test Outage A",
                            start_time: Time.find_zone("Samoa").now + 24.hours)
    assert outage1.save
    outage2 = Outage.create(account: account,
                            active: true,
                            causes_loss_of_service: true,
                            completed: false,
                            description: "A description of Test Outage B",
                            end_time: Time.find_zone("Samoa").now + 50.hours,
                            name: "#{account_name} Test Outage B",
                            start_time: Time.find_zone("Samoa").now + 48.hours)
    assert outage2.save

    #  Events
    event1 = Event.create(handled: true,
                          outage: outage1,
                          text: "Test Event on #{outage1.name}",
                          event_type: :outage)
    assert event1.save
    event2 = Event.create(handled: true,
                          outage: outage2,
                          text: "Test Event on #{outage2.name}",
                          event_type: :outage)
    assert event2.save

    # Watches
    watch1_main = Watch.create(active: true, user: user_main, watched:outage1)
    assert watch1_main.save
    watch2_main = Watch.create(active: true, user: user_main, watched:outage2)
    assert watch2_main.save
    watch1_extra = Watch.create(active: true, user: user_extra, watched:outage1)
    assert watch1_extra.save
    watch2_extra = Watch.create(active: true, user: user_extra, watched:outage2)
    assert watch2_extra.save

    # Notifications
    notification = Notification.create(event: event1,
                                       watch: watch1_extra,
                                       notified: false,
                                       notification_type: :email)

    #  Return the main user
    user_main
  end

  def set_all_email(user)
    user.notify_me_before_outage = false
    user.notify_me_on_outage_changes = false
    user.notify_me_on_note_changes = false
    user.notify_me_on_outage_complete = false
    user.notify_me_on_overdue_outage = false
    user.preference_email_time = "11:00"
    user.preference_individual_email_notifications = false
    user.preference_notify_me_by_email = true
  end

end
