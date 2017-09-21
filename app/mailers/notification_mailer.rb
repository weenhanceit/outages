class NotificationMailer < ApplicationMailer
  def notification_email(user)
    # puts "-------- #{__FILE__}:#{__LINE__}  ------- Class: #{self.class} ---"
    @user = user
    # @notification_list = notifications
    # @sign_in_url = "https://outages.weenhanceit.com/users/sign_in"
    mail(to: @user.email,
         subject: "Latest Notifications from Outages App")
  end
end
