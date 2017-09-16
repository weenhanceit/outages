require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase

  test "notifications" do
    puts "----- #{__FILE__} #{__LINE__} -----"
    user = users(:test_mail_recepient_1)
    # Check that we are expecting to handle 2 email notifications
    assert_equal 2, user.outstanding_notifications(:email).size

    email = NotificationMailer.notification_email(user)
    # puts "nmt.rb  #{__LINE__}: Email class: #{email.class} ========================="
    # puts "nmt.rb #{__LINE__}: - methods: #{email.methods.size} ========================="
    # puts "nmt.rb #{__LINE__}: - methods: #{email.methods.sort} ========================="
    #
    # puts "nmt.rb  #{__LINE__}: Email: #{email.inspect}"
    assert_emails 1 do
      puts "nmt.rb  #{__LINE__}: WTF"
      puts "nmt.rb  #{__LINE__}: WTF2"
      email.deliver_now
    end

    assert_equal ["noreply@weenhanceit.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Latest Notifications from Outages App", email.subject
    # assert_equal read_fixture("notification_email_html").join,
    #   email.body.to_s

    # assert_equal read_fixture("notification_email_text").join,
    #   email.text_part.body.to_s

    # Check that we are now expecting no outstanding email notifications
    assert_equal 0, user.outstanding_notifications(:email).size


    # puts email.body.to_s
  end
end
