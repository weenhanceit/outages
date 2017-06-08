##
# A single outage.
class Outage < ApplicationRecord
  belongs_to :account
  has_many :cis_outages, inverse_of: :outage
  has_many :cis, through: :cis_outages
  has_many :contributors, inverse_of: :outage
  has_many :events, inverse_of: :outage
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched

  validates :active,
    :causes_loss_of_service,
    :completed,
    inclusion: { in: [true, false], message: "can't be blank" }

  default_scope { where(active: true) }
end
