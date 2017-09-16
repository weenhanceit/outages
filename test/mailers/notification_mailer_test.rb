require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase

  test "notifications" do
    # puts "----- #{__FILE__} #{__LINE__} -----"
    user = users(:test_mail_recepient_1)
    # Check that we are expecting to handle 2 email notifications
    assert_equal 2, user.outstanding_notifications(:email).size

    email = NotificationMailer.notification_email(user)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@weenhanceit.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Latest Notifications from Outages App", email.subject


    # puts email.body.to_s
  end
end
