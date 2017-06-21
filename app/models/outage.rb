##
# A single outage.
class Outage < ApplicationRecord
  include Watched

  belongs_to :account
  has_many :cis_outages, inverse_of: :outage
  accepts_nested_attributes_for :cis_outages, allow_destroy: true
  has_many :cis, through: :cis_outages
  accepts_nested_attributes_for :cis
  has_many :contributors, inverse_of: :outage
  has_many :events, inverse_of: :outage
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched, autosave: true

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
    # puts "OUTAGE: #{inspect}"
    update_attributes(cis_outages_attributes: attributes)
    # puts "OUTAGE: #{inspect}"
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
    if date.beginning_of_day < end_time &&
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
end
