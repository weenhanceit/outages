# frozen_string_literal: true

##
# A configuration item, which can be hardware, software, service, etc.
class Ci < ApplicationRecord
  include Watched
  include PgSearch
  multisearchable against: %i[name description]

  belongs_to :account
  # Putting `inverse_of: ...` on the next four lines causes the association
  # to give incorrect answers.
  has_many :parent_links,
    foreign_key: :child_id,
    class_name: "CisCi",
    dependent: :destroy
  accepts_nested_attributes_for :parent_links, allow_destroy: true
  has_many :parents, through: :parent_links, class_name: "Ci"
  has_many :child_links,
    foreign_key: :parent_id,
    class_name: "CisCi",
    dependent: :destroy
  accepts_nested_attributes_for :child_links, allow_destroy: true
  has_many :children, through: :child_links, class_name: "Ci"
  has_many :cis_outages
  has_many :outages, through: :cis_outages
  has_many :notes, as: :notable
  has_many :tags, as: :taggable
  # TODO: need `after_add :schedule_reminders`?
  # FIXME: Need to think about callback for watches added to ci to generate
  # reminder job.  This possibly should be a callback on create watch
  has_many :watches, as: :watched, inverse_of: :watched, dependent: :destroy
  accepts_nested_attributes_for :watches,
    reject_if: lambda { |attrs|
      !ActiveModel::Type::Boolean.new.cast(attrs[:active]) && attrs[:id].blank?
    }

  validates :active,
    inclusion: { in: [true, false], message: "can't be blank" }

  validates_presence_of :name

  default_scope { where(active: true) }

  attr_accessor :css_class

  ##
  # Scope returning the ci and all its dependents
  def self.affected_cis(ci)
    where(id: (ci.ancestors_affected << ci).uniq)
  end

  ##
  # All the ancestor Cis of a CI
  def ancestors
    parents + parents.map(&:ancestors).flatten
  end

  # All the ancestor Cis of a Ci that are affected by an outage
  # to this Ci
  # TODO: add the CI (self) to this array, and remove it where it's redundant.
  # TODO: or maybe not. Think about it.
  def ancestors_affected
    ancestors
  end

  ##
  # Return all the CIs for the account.
  # Those that could be assigned as children of this CI are visible.
  # That means they're not already children, and they're not ancestors.
  # If they were ancestors, this would not be a DAG.
  # CIs that can't be children are hidden.
  # This method will raise an ArgumentError if you don't pass an
  # account, and the outage doesn't have an account assigned yet.
  def available_for_children(account = self.account)
    raise ArgumentError if account.nil?
    ((children + ancestors)
      .each { |ci| ci.css_class = "list-maintenance-hidden" }) +
      (all_cis_but_me - children - ancestors)
  end

  ##
  # Process the attributes.
  # TODO: Describe this whole technique somewhere.
  def available_for_children_attributes=(attributes)
    # puts "available_for_children_attributes: #{attributes.inspect}"
    # puts "OUTAGE: #{inspect}"
    assign_attributes(child_links_attributes: attributes)
    # puts "OUTAGE: #{inspect}"
  end

  ##
  # Return all the CIs for the account.
  # Those that could be assigned as parents of this CI are visible.
  # That means they're not already parents, and they're not descendants.
  # If they were descendants, this would not be a DAG.
  # CIs that can't be parents are hidden.
  # This method will raise an ArgumentErrorlist-maintenance-hidden if you don't pass an
  # account, and the outage doesn't have an account assigned yet.
  def available_for_parents(account = self.account)
    raise ArgumentError if account.nil?
    # puts "all_cis_but_me: #{all_cis_but_me.map(&:name).join(", ")}"
    # puts "parents: #{parents.map(&:name).join(", ")}"
    # puts "descendants: #{descendants.map(&:name).join(", ")}"
    ((parents + descendants)
      .each { |ci| ci.css_class = "list-maintenance-hidden" }) +
      (all_cis_but_me - parents - descendants)
  end

  ##
  # Process the attributes.
  # TODO: Describe this whole technique somewhere.
  def available_for_parents_attributes=(attributes)
    # puts "available_for_parents_attributes: #{attributes.inspect}"
    # puts "OUTAGE: #{inspect}"
    assign_attributes(parent_links_attributes: attributes)
    # puts "OUTAGE: #{inspect}"
  end

  ##
  # All the descendant CIs of a CI
  def descendants
    children + children.map(&:descendants).flatten
  end

  # All the descendant Cis of a Ci that are watched indirectly
  # TODO: add the CI (self) to this array, and remove it where it's redundant.
  # TODO: or maybe not. Think about it.
  def descendants_affected
    descendants
  end

  def affected_by_outages
    (outages + descendants.flat_map(&:outages)).uniq
  end

  def pg_search_document_attrs
    attrs = super
    # puts "PgSearchDocument#pg_search_document_attrs: #{attrs.inspect}"
    attrs.merge(account_id: account_id)
  end

  private

  ##
  # Return all the CIs for the account, expect self, if self has been saved.
  def all_cis_but_me
    all = Ci.where(account: account)
    all = all.where.not(id: id) if id
    all
  end
end
