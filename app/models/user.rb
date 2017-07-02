##
# Represents a user.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
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
    :preference_notify_me_by_email,
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

  ##
  # Filter outages based on criteria specified by the user, passed in the
  # params hash.
  def filter_outages(params)
    scope = account.outages.where(active: true)
    if params[:frag].present?
      scope = scope.where("name like ?", "%#{params[:frag]}%")
    end

    # EXCLUDED: end <= earliest || latest <= start
    # EXCLUDED: earliest <= end || start <= latest
    if params[:earliest].present?
      earliest = params[:earliest]
      earliest = Time.zone.parse(earliest) if earliest.is_a?(String)
      scope = scope.where("coalesce(end_time, 'infinity') > ?", earliest)
    end

    if params[:latest].present?
      latest = params[:latest]
      latest = Time.zone.parse(latest) if latest.is_a?(String)
      scope = scope.where("? > coalesce(start_time, end_time)", latest)
    end

    # puts params.inspect
    # Put this condition at the end of this method, because it is the one
    # that will (may?) return an Array.
    if params[:watching].present? && params[:watching] == "Of interest to me"
      # FIXME: Unfake this when we make this
      scope = scope.watched_outages(self)
    end

    # puts scope.is_a?(Array) ?
    #    "scope is an Array" : "SCOPE.TO_SQL: #{scope.to_sql}"

    scope
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
