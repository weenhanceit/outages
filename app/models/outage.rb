# frozen_string_literal: true

##
# A single outage.
class Outage < ApplicationRecord
  include Watched
  include PgSearch
  multisearchable against: %i[name description]

  belongs_to :account
  has_many :cis_outages,
    inverse_of: :outage,
    dependent: :destroy,
    autosave: true
  accepts_nested_attributes_for :cis_outages, allow_destroy: true
  has_many :cis, through: :cis_outages
  accepts_nested_attributes_for :cis
  # has_many :affected_cis, through: :cis_outages, source: :affected_cis
  has_many :contributors, inverse_of: :outage
  has_many :events, inverse_of: :outage, dependent: :destroy
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches,
    as: :watched,
    inverse_of: :watched,
    dependent: :destroy,
    after_add: :schedule_reminders
  accepts_nested_attributes_for :watches,
    reject_if: lambda { |attrs|
      !ActiveModel::Type::Boolean.new.cast(attrs[:active]) && attrs[:id].blank?
    }

  validates :active,
    :causes_loss_of_service,
    :completed,
    inclusion: { in: [true, false], message: "can't be blank" }

  default_scope { where(active: true) }

  ##
  # Return the available but not assigned CIs for the outage.
  # This will blow up if you don't pass an account, and the outage doesn't
  # have an account assigned yet.
  def available_cis(account = self.account)
    # puts "AVAILABLE: #{(Ci.where(account: account) - cis).inspect}"
    Ci.where(account: account) - cis
  end

  ##
  # This is needed to make the form helpers treat the available_cis as
  # an association.
  def available_cis_attributes=(attributes)
    # puts "available_cis_attributes: #{attributes.inspect}"
    # logger.debug "Changed: #{changed?} OUTAGE: #{inspect}"
    assign_attributes(cis_outages_attributes: attributes)
    # logger.debug "Changed: #{changed?} OUTAGE: #{inspect}"
  end

  ##
  # true if active has changed and it is now true
  def became_active?
    active_changed? && active
  end

  ##
  # true if active has changed and it is now false
  def became_inactive?
    active_changed? && !active
  end

  ##
  # true if complete has changed and it is now true
  def became_completed?
    completed_changed? && completed
  end

  ##
  # true if complete has changed and it is now true
  def became_incompleted?
    completed_changed? && !completed
  end

  ##
  # If end time is on the date, return end time.
  # If end time is after the date, but start time is on the date or before,
  # return the start of the next day.
  # Else raise an exception
  def end_time_on_date(date)
    # puts "end_time_on_date:"
    # puts "date.beginning_of_day: #{date.beginning_of_day}"
    # puts "start_time: #{start_time}"
    # puts "(date + 1).beginning_of_day: #{(date + 1).beginning_of_day}"
    # puts "end_time: #{end_time}"
    if end_time.nil?
      start_time_on_date(date)
    elsif date.beginning_of_day < end_time &&
          end_time <= (date + 1).beginning_of_day
      # puts "returning end time: #{end_time}"
      end_time
    elsif (date + 1).beginning_of_day < end_time &&
          start_time < (date + 1).beginning_of_day
      # puts "returning end of date: #{(date + 1).beginning_of_day}"
      (date + 1).beginning_of_day
    else
      raise ArgumentError
    end
  end

  ##
  # Return the combination of notes and events for an outage.
  # Some events are not relevant for histories.
  # Default is to return in reverse chronological order of creation.
  def histories(order = "desc")
    (notes + events.except_note_events).sort do |a, b|
      order != "asc" ?
                b.created_at <=> a.created_at :
                a.created_at <=> b.created_at
    end
  end

  ##
  # true complete has changed and is the only attribute changed
  def only_completed_changed?
    changed == ["completed"]
  end

  def pg_search_document_attrs
    attrs = super
    # puts "PgSearchDocument#pg_search_document_attrs: #{attrs.inspect}"
    attrs.merge(account_id: account_id)
  end

  ##
  # If start time is on the date, return start time.
  # If start time is before the date, but end time is on the date or after,
  # return the start of the day.
  # Else raise an exception
  def start_time_on_date(date)
    # puts "start_time_on_date:"
    # puts "date.beginning_of_day: #{date.beginning_of_day}"
    # puts "start_time: #{start_time}"
    # puts "(date + 1).beginning_of_day: #{(date + 1).beginning_of_day}"
    # puts "end_time: #{end_time}"
    if date.beginning_of_day <= start_time &&
       start_time < (date + 1).beginning_of_day
      # puts "returning start time: #{start_time}"
      start_time
    elsif start_time < date.beginning_of_day &&
          date.beginning_of_day < end_time
      # puts "returning start of date: #{date.beginning_of_day}"
      date.beginning_of_day
    else
      raise ArgumentError
    end
  end

  ##
  # All users watching the outage via any way.
  def users
    watches_unique_by_user.map(&:user)
  end

  ##
  # An arbitrary single watch per user for the outage..
  def watches_unique_by_user
    (watches +
      (cis + cis.map(&:ancestors).flatten)
        .map(&:watches)
        .flatten)
      .uniq(&:user)
  end

  ##
  # A Relation for all the
  # All the outages the user is directly watching
  # All outages the directly affect a CI that the user is watching
  # All the outages that have a CI that has a descendant of a CI
  # that the user is watching
  # The previous could be:
  # If the user is watching a CI that is an ancestor of a CI in an outage,
  # include that outage
  def self.watched_outages(user)
    (directly_watched_outages(user) + watched_by_cis(user)).uniq

    # directly_watched_outages(user).or(directly_watched_by_cis(user))
    # self.directly_watched_outages(user)
    # watches.where(watched_type: "Outage").first.w
    # watches.where(watched_type: "Ci").first.watched.outages
    # where(id: 567011998)
  end

  def self.directly_watched_outages(user)
    scope = joins(:watches).where(watches: { user_id: user })
    # puts "#{__LINE__} scope: #{scope.to_sql}"
    scope
  end

  # TODO: This method isn't needed anymore
  def self.directly_watched_by_cis(user)
    joins(cis: :watches).where(watches: { user_id: user })
  end

  # TODO: This method isn't needed anymore
  def self.indirectly_watched_by_cis(user)
    ci_watches = user.watches.where(watched_type: "Ci")
    # puts "indirectly_watched_by_cis: #{ci_watches.inspect}"
    watched_cis = ci_watches.map do |watch|
      # puts "indirectly_watched_by_cis: #{watch.inspect}"
      # puts "indirectly_watched_by_cis: " \
      # "#{watch.watched.descendants_affected.inspect}"
      # TODO: put this in to combine methods + [watch.watched]
      watch.watched.descendants_affected
    end.flatten.uniq
    # puts "indirectly_watched_by_cis: #{watched_cis.inspect}"

    scope = joins(:cis_outages).where(cis_outages: { ci_id: watched_cis })
    # puts "indirectly_watched_by_cis: #{scope.to_sql}"
    scope
    # joins(cis: { affected_cis: :watches }).where(watches: {user_id: user})
  end

  def self.watched_by_cis(user)
    # directly_watched_by_cis(user) +
    # indirectly_watched_by_cis(user)
    ci_watches = user.watches.where(watched_type: "Ci")
    # puts "watched_by_cis: #{ci_watches.inspect}"
    watched_cis = ci_watches.map do |watch|
      # puts "watched_by_cis: #{watch.inspect}"
      # puts "watched_by_cis: #{watch.watched.descendants_affected.inspect}"
      watch.watched.descendants_affected + [watch.watched]
    end.flatten.uniq
    # puts "watched_by_cis: #{watched_cis.inspect}"

    scope = joins(:cis_outages).where(cis_outages: { ci_id: watched_cis })
    # puts "#{__LINE__} scope: #{scope.to_sql}"
    scope
    # joins(cis: { affected_cis: :watches }).where(watches: {user_id: user})
  end

  private

  def schedule_reminders(watch)
    if watch.user.notify_me_before_outage
      # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"
      # Jobs::ReminderJob.schedule(self, watch.user)
      # Rails.logger.debug " ==> Phil's Debug within #{__FILE__} at line #{__LINE__} ----------------------------"
    end
  end
end
