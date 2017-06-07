##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  belongs_to :account
  has_many :parents, foreign_key: :parent_id, class_name: "CisCi", inverse_of: :parent
  has_many :children, foreign_key: :child_id, class_name: "CisCi", inverse_of: :child
  has_many :cis_outages, inverse_of: :ci
  has_many :outages, through: :cis_outages
  has_many :parents, through: :cis_cis
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched
end
