##
# Represents a user.
class User < ApplicationRecord
  belongs_to :account
  has_many :contributors, inverse_of: :user
  has_many :notes, inverse_of: :user
  has_many :watches, inverse_of: :user
  has_many :notifications, through: :watches

  validates :active,
    :notify_me_before_outage,
    :notify_me_on_note_changes,
    :notify_me_on_outage_changes,
    :notify_me_on_outage_complete,
    :notify_me_on_overdue_outage,
    :preference_individual_email_notifications,
    :preference_notifiy_me_by_email,
    :privilege_account,
    :privilege_edit_cis,
    :privilege_edit_outages,
    :privilege_manage_users,
    inclusion: { in: [true, false], message: "can't be blank" }

  validates_presence_of :email

  default_scope { where(active: true) }

  def can_edit_outages?
    privilege_edit_outages
  end

  def can_edit_cis?
    privilege_edit_cis
  end

  # Provide an array of outstanding (notified false) online notifications
  # for the user
  def outstanding_online_notifications
    ## TODO: This class method generates notifications.  It is anticipated
    ## this will be run as a background task.  It is places here during
    ## development and NEED to re-evaluate where this should wind up
    Services::GenerateNotifications.call
    notifications.where(notified: false,
                        notification_type: "online")
                 .order(created_at: :desc)
  end

  ##
  # Used in the prototype. Probably not needed in the near future.
  def user_privilege_text
    name
    # if privilege_account
    #   "Domain Admin"
    # elsif privilege_manage_users
    #   "User Admin (Manager)"
    # elsif (privilege_edit_cis || privilege_edit_outages)
    #   "Can Edit CIs/Outages"
    # else
    #   "Basic User (Read Only)"
    # end
  end
end
