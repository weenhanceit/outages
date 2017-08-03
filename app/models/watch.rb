##
# Represents a user watching for outages on a CI, or watching an outage
# directly.
class Watch < ApplicationRecord
  belongs_to :user
  belongs_to :watched, -> { unscope(where: :active) }, polymorphic: true
  belongs_to :ci,
    -> { where(watches: { watched_type: "Ci" }) },
    foreign_key: :watched_id
  belongs_to :outage,
    -> { where(watches: { watched_type: "Outage" }) },
    foreign_key: :watched_id
  has_many :notifications, inverse_of: :watches

  default_scope { where(active: true) }

  ##
  # Get one watch that connects a user with an outage.
  # The prioritization is arbitrary:
  #
  # 1. Direct CI watch
  # 2. Indirect CI watch
  # 3. Outage watch
  def self.unique_watch_for(user, outage)
    watch = where(user: user, cis_outages: { outage_id: outage })
            .joins(ci: [:cis_outages]).first
    return watch if watch

    puts where(user: user, cis_outages: { outage_id: outage })
      .joins(ci: [r_descendants: [:cis_outages]]).to_sql
    watch = where(user: user, cis_outages: { outage_id: outage })
            .joins(ci: [r_descendants: [:cis_outages]]).first
    return watch if watch

    find_by(user: user, outage: outage)
  end
end
