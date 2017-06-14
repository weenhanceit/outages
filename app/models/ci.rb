##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  belongs_to :account
  # Putting `inverse_of: ...` on the next four lines causes the association
  # to give incorrect answers.
  has_many :parent_links, foreign_key: :child_id, class_name: "CisCi"
  accepts_nested_attributes_for :parent_links
  has_many :parents, through: :parent_links, class_name: "Ci"
  has_many :child_links, foreign_key: :parent_id, class_name: "CisCi"
  has_many :children, through: :child_links, class_name: "Ci"
  has_many :cis_outages
  has_many :outages, through: :cis_outages
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  has_many :watches, as: :watched

  validates :active,
   inclusion: { in: [true, false], message: "can't be blank" }

  validates_presence_of :name

  default_scope { where(active: true) }

  ##
  # All the ancestor Cis of a CI
  def ancestors
    parents + parents.map(&:ancestors).flatten
  end

  # All the ancestor Cis of a Ci that are affected by an outage
  # to this Ci
  def ancestors_affected
    ancestors
  end

  ##
  # Return the CIs that could be parents of this CI.
  # That means they're not already parents, and they're not children.
  # If they were children, this would not be a DAG.
  # This will blow up if you don't pass an account, and the outage doesn't
  # have an account assigned yet.
  def available_for_children(account = self.account)
    all_cis_but_me - children - ancestors
  end

  ##
  # Process the attributes.
  # TODO: Describe this whole technique somewhere.
  def available_for_children_attributes=(attributes)
  end

  ##
  # Return the CIs that could be parents of this CI.
  # That means they're not already parents, and they're not children.
  # If they were children, this would not be a DAG.
  # This will blow up if you don't pass an account, and the outage doesn't
  # have an account assigned yet.
  def available_for_parents(account = self.account)
    all_cis_but_me - parents - descendants
  end

  ##
  # Process the attributes.
  # TODO: Describe this whole technique somewhere.
  def available_for_parents_attributes=(attributes)
    puts "available_for_parents_attributes: #{attributes.inspect}"
    puts "OUTAGE: #{inspect}"
    update_attributes(parent_links_attributes: attributes)
    puts "OUTAGE: #{inspect}"
  end

  ##
  # All the descendant CIs of a CI
  def descendants
    children + children.map(&:descendants).flatten
  end

  def all_cis_but_me
    all = Ci.where(account: account)
    all = all.where.not(id: id) if id
    all
  end
end
