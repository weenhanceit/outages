require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "notifications" do
    user = users(:test_mail_recepient_1)

    email = NotificationMailer. notification_email(user)

    # Check that we are expecting to handle 2 email notifications
    assert_equal 2, user.outstanding_notifications(:email).size

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@weenhanceit.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Latest Notifications", email.subject
    # assert_equal read_fixture("notification_email_html").join,
    #   email.body.to_s

    # assert_equal read_fixture("notification_email_text").join,
    #   email.text_part.body.to_s

    # Check that we are now expecting no outstanding email notifications
    assert_equal 0, user.outstanding_notifications(:email).size


    # puts email.body.to_s
  end
end
