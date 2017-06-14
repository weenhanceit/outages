##
# A single outage.
class Outage < ApplicationRecord
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

  def watched
    watches.present?
  end
end
