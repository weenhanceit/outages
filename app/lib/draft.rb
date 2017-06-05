module Draft
  def on_line_notifications(user_id)
    Notifications.show_to_user_on_line(user_id: user_id)
  end

  def e_mail_notifications(user_id)
    Notifications.pending_email_notifications(user_id: user_id)
  end
end



class Notifications
  def mark_as_dont_show_to_user_on_line
    # TBD
    save
  end

  def mark_as_show_to_user_on_line
    # TBD
    save
  end

  def mark_as_e_mail_sent
    # TBD
    save
  end

  def self.show_to_user_on_line(user_id)
    # find...
  end

  def self.users_with_pending_email
  end
end

class EMailDaemon
  def main
    Notifications.users_with_pending_email.each |user| do
      # Something that batches the Notifications
      # e.g. if the start and/or end time changed multiple times,
      # just show the last start and end time (bonux marks for
      # making sure that the final start and end time are different
      # than they were when you started.)
      if user.has_email_to_send?
        user.send_e_mail_notification
      end
    end
  end
end
