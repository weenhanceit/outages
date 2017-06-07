##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  belongs_to :account
  has_many :parents, foreign_key: :child_id, source: :cis_ci, inverse_of: :parent
  has_many :children, foreign_key: :parent_id, source: :cis_ci, inverse_of: :child
  has_many :outages, through: :cis_outages
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched
end
