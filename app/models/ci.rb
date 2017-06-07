##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  belongs_to :account
  # Putting `inverse_of: ...` on the next two lines causes the association
  # to give incorrect answers.
  has_many :parents, foreign_key: :child_id, class_name: "CisCi"
  has_many :children, foreign_key: :parent_id, class_name: "CisCi"
  has_many :outages, through: :cis_outages
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched
end
