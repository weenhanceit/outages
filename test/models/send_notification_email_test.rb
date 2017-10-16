# frozen_string_literal: true

require "test_helper"
require "helpers/set_config_01.rb"
class SendNotificationEmailTest < ActionMailer::TestCase
  # include ActiveJob::TestHelper
  include TestCases

  test "no notifications no email" do
    user = setup_config01("Our Test Account")
    # puts "snet.rb #{__LINE__}: #{user.name}"

    # Quick Check our configuration
    assert_equal 0, user.outstanding_notifications(:email).size
    assert_equal 2, user.outages.size

    #  Check that no emails are sent, no notifications were marked notified
    assert_no_difference "Notification.where(notified: false).size" do
      assert_emails 0 do
        Services::SendNotificationEmail.call(user)
      end
    end
  end

  test "1 notification 1 email" do
    #  User config01 out of the box, then add our notification
    user = setup_config01("Our Test Account")
    event = Event.where(outage: user.outages[0]).first
    watch = Watch.where(user: user, watched: user.outages[0]).first

    notification = Notification.create(event: event,
                                       watch: watch,
                                       notified: false,
                                       notification_type: :email)

    # Quick Check our configuration
    assert_equal 1, user.outstanding_notifications(:email).size
    assert_equal 2, user.outages.size

    #  Check that no emails are sent, no notifications were marked notified
    email = nil
    assert_difference "Notification.where(notified: false).size", -1 do
      assert_emails 1 do
        email = Services::SendNotificationEmail.call(user)
      end
    end

    # Check that we are now expecting no outstanding email notifications
    assert_equal 0, user.outstanding_notifications(:email).size

    # Now check the email
    assert email.is_a?(ActionMailer::MessageDelivery)
    assert_equal "Latest Notifications from Outages App", email.subject
    assert_equal user.email, email.to[0]
    expected = user.name.gsub("(", "\\(").gsub(")", "\\)")
    expected = "Hello, #{expected}"
    assert_match(Regexp.new(expected), email.body.to_s)
    expected = notification.event.outage.name
    assert_match(Regexp.new(expected), email.body.to_s)
    expected = notification.event.text
    assert_match(Regexp.new(expected), email.body.to_s)
  end
  test "2 notifications 1 email" do
    #  User config01 out of the box, then add our notifications
    user = setup_config01("Our Test Account")
    event1 = Event.where(outage: user.outages[0]).first
    event2 = Event.where(outage: user.outages[1]).first
    watch1 = Watch.where(user: user, watched: user.outages[0]).first
    watch2 = Watch.where(user: user, watched: user.outages[1]).first

    notification1 = Notification.create(event: event1,
                                        watch: watch1,
                                        notified: false,
                                        notification_type: :email)
    notification2 = Notification.create(event: event2,
                                        watch: watch2,
                                        notified: false,
                                        notification_type: :email)

    # Quick Check our configuration
    assert_equal 2, user.outstanding_notifications(:email).size
    assert_equal 2, user.outages.size

    #  Check that no emails are sent, no notifications were marked notified
    email = nil
    assert_difference "Notification.where(notified: false).size", -2 do
      assert_emails 1 do
        email = Services::SendNotificationEmail.call(user)
      end
    end

    # Check that we are now expecting no outstanding email notifications
    assert_equal 0, user.outstanding_notifications(:email).size

    # Now check the email
    assert email.is_a?(ActionMailer::MessageDelivery)
    assert_equal "Latest Notifications from Outages App", email.subject
    assert_equal user.email, email.to[0]
    expected = user.name.gsub("(", "\\(").gsub(")", "\\)")
    expected = "Hello, #{expected}"
    assert_match(Regexp.new(expected), email.body.to_s)
    expected = notification1.event.outage.name
    assert_match(Regexp.new(expected), email.body.to_s)
    expected = notification1.event.text
    assert_match(Regexp.new(expected), email.body.to_s)
    expected = notification2.event.outage.name
    assert_match(Regexp.new(expected), email.body.to_s)
  end
end
