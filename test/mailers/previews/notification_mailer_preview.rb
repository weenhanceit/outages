# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def notification_email
    # Use a demo user for this
    NotificationMailer.notification_email(demo_user)
  end

  private

  def demo_user
    account = Account.find_by(name: "for email demo only")
    account = Account.create(name: "for email demo only") if account.nil?

    user = User.where(account: account).first
    if user.nil?
      user = User.create(account: account,
                         name: "I'm just a demo",
                         email: "imademo@example.com",
                         password: "secret",
                         notify_me_on_outage_changes: true,
                         notify_me_on_outage_complete: false,
                         notify_me_before_outage: false,
                         notify_me_on_note_changes: false,
                         notify_me_on_overdue_outage: false,
                         preference_individual_email_notifications: false,
                         preference_notify_me_by_email: true,
                         privilege_account: false,
                         privilege_edit_cis: true,
                         privilege_edit_outages: true,
                         privilege_manage_users: false)

    end
    outage = Outage.where(account: account).first
    if outage.nil?
      outage = Outage.create(account: account,
                             active: true,
                             causes_loss_of_service: true,
                             completed: false,
                             name: "outage for demo",
                             start_time: Time.new + 1.day)
      outage.start_time = Time.zone.now + 1.day
      outage.end_time = outage.start_time + 1.hour
      outage.save
    end

    watch = Watch.where(user: user).first
    watch = Watch.create(user: user, watched: outage, active: true) if watch.nil?

    event = Event.where(outage: outage).first
    if event.nil?
      event = Event.create(outage: outage,
                           event_type: :outage,
                           text: "Something happened",
                           handled: true)
    end
    event.created_at = Time.zone.now - 3.minutes
    event.save

    notification = Notification.where(event: event).first
    notification = Notification.new(event: event) if notification.nil?
    notification.notified = false
    notification.notification_type = :email
    notification.watch = watch
    notification.save

    user.reload

    user
  end
end
