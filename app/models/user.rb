##
# Represents a user.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :timeoutable, :trackable, :validatable
  belongs_to :account, optional: true
  has_many :contributors, inverse_of: :user
  has_many :notes, inverse_of: :user
  has_many :watches, inverse_of: :user
  has_many :direct_outages,
    through: :watches,
    source: :watched,
    source_type: "Outage"
  has_many :cis, through: :watches, source: :watched, source_type: "Ci"
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

  validate :at_least_one_account_admin
  validate :at_least_one_user_admin

  validates_presence_of :email
  validates_presence_of :preference_email_time,
    if: -> { preference_notify_me_by_email && !preference_individual_email_notifications }

  default_scope { where(active: true) }

  before_validation :set_defaults

  def can_edit_outages?
    privilege_edit_outages
  end

  def can_edit_cis?
    privilege_edit_cis
  end

  ##
  # User name to be displayed by the application
  def display_name
    # puts "u.rb #{__LINE__}: name: #{name} name.blank?: #{name.blank?}"
    # # if !name.nil?
    #   # puts "u.rb #{__LINE__}: name: #{name} name.blank?: #{name.blank?} strip [#{name.strip}]"
    #   puts "u.rb #{__LINE__}: name: #{name} name.nil?: #{name.nil?}"
    #   unless name.nil?
    #     puts "u.rb #{__LINE__}: name: #{name} name.nil?: #{name.nil?}  strip [#{name.strip}]"
    #     self.name = name.strip
    #   end
    #   # name = " xd"
    # # end
    # puts "u.rb #{__LINE__}: name: #{name} name.blank?: #{name.blank?}"
    name.blank? ? email : name
  end

  ##
  # Filter outages based on criteria specified by the user, passed in the
  # params hash. If the earliest and latest are strings, they're now
  # considered to be dates, and are forced to dates if they're not.
  # Also, one day is added if the date is a string.
  # FIXME: We should really change the test cases.
  def filter_outages(params)
    # puts " ------------------#{__LINE__}-------------------------------------"
    # logger.debug "user.rb #{__LINE__}: PARAMS: #{params.inspect}"
    scope = account.outages.where(active: true, completed: false)
    # FIXME: Make this case-insensitive
    if params[:frag].present?
      scope = scope.where("lower(name) like ?", "%#{params[:frag].downcase}%")
    end

    scope = scope.unscope(where: :completed) if get_completed_too?(params)

    # EXCLUDED: end <= earliest || latest <= start
    # EXCLUDED: earliest <= end || start <= latest
    if params[:earliest].present?
      earliest = params[:earliest]
      earliest = Time.zone.parse(earliest) if earliest.is_a?(String)
      scope = scope.where("coalesce(end_time, 'infinity') > ?", earliest)
    end

    if params[:latest].present?
      latest = params[:latest]
      # Add one day when coming from params because end time is excluded.
      latest = Time.zone.parse(latest) + 1.day if latest.is_a?(String)
      scope = scope.where("? > coalesce(start_time, '-infinity')", latest)
    end

    # puts params.inspect
    # Put this condition at the end of this method, because it is the one
    # that will (may?) return an Array.
    if params[:watching].present? && params[:watching] == "Of interest to me"
      scope = scope.watched_outages(self)
    end

    # puts scope.is_a?(Array) ?
    #    "scope is an Array" : "SCOPE.TO_SQL: #{scope.to_sql}"

    # FIXME: sort this by start time, end time, and name
    scope
  end

  ##
  # Figure out if the user wants to get completed outages as well as
  # pending outages.
  def get_completed_too?(params)
    params.fetch(:completed, "0") == "1"
  end

  ##
  # ALl outages currently watched by user.
  def outages
    (direct_outages +
      cis.map(&:outages).flatten +
      cis.map(&:descendants).flatten.map(&:outages).flatten).uniq
  end

  # Returns all outstanding notifications of a given notificaton type
  def outstanding_notifications(notification_type)
    # TODO: Review if this should do a reload
    reload
    notifications.where(notified: false,
                        notification_type: notification_type)
                 .order(created_at: :desc)
  end

  ##
  # Set the defaults so validations will pass when someone signs up.
  # This is in the model so it would happen when Devise creates a user.
  def set_defaults
    # puts "SETTING DEFAULTS"
    # FIXME: Add default for time of daily e-mail.
    self.notify_me_before_outage = false if notify_me_before_outage.nil?
    self.notify_me_on_note_changes = false if notify_me_on_note_changes.nil?
    self.notify_me_on_outage_changes = true if notify_me_on_outage_changes.nil?
    self.notify_me_on_outage_complete = true if notify_me_on_outage_complete.nil?
    self.notify_me_on_overdue_outage = false if notify_me_on_overdue_outage.nil?
    self.preference_individual_email_notifications = false if preference_individual_email_notifications.nil?
    self.preference_notify_me_by_email = false if preference_notify_me_by_email.nil?
    # NOTE: User created by signing up is a super-user. This mignt not always
    # be true.
    self.privilege_account = true if privilege_account.nil?
    self.privilege_edit_cis = true if privilege_edit_cis.nil?
    self.privilege_edit_outages = true if privilege_edit_outages.nil?
    self.privilege_manage_users = true if privilege_manage_users.nil?
    # puts "self.inspect: #{inspect}"
  end

  private

  def at_least_one_account_admin
    if removing_account_admin &&
       account &&
       account.users.where(privilege_account: true).where.not(id: id).empty?
      errors[:base] << "This is the last account manager."
    end
  end

  def at_least_one_user_admin
    if removing_user_admin &&
       account &&
       account.users.where(privilege_manage_users: true).where.not(id: id).empty?
      errors[:base] << "This is the last user manager."
    end
  end

  def removing_account_admin
    changed_attributes[:privilege_account] || changed_attributes[:active]
  end

  def removing_user_admin
    changed_attributes[:privilege_manage_users] || changed_attributes[:active]
  end
end
