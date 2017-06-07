##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  belongs_to :account
  # Putting `inverse_of: ...` on the next four lines causes the association
  # to give incorrect answers.
  has_many :parent_links, foreign_key: :child_id, class_name: "CisCi"
  has_many :parents, through: :parent_links, class_name: "Ci"
  has_many :child_links, foreign_key: :parent_id, class_name: "CisCi"
  has_many :children, through: :child_links, class_name: "Ci"
  has_many :outages, through: :cis_outages
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched

  validates :active, inclusion: { in: [true, false], message: "can't be blank" }
end
