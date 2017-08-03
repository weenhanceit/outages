##
# Represents a user watching for outages on a CI, or watching an outage
# directly.
class Watch < ApplicationRecord
  belongs_to :user
  belongs_to :watched, -> { unscope(where: :active) }, polymorphic: true
  # belongs_to :ci,
  #   -> { where(watches: { watched_type: "Ci" }).references(:watches) },
  #   foreign_key: :watched_id
  # belongs_to :outage,
  #   -> { where(watches: { watched_type: "Outage" }).references(:watches) },
  #   foreign_key: :watched_id
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
    watch = find_by(user: user, watched_type: "Ci", watched_id: outage.cis)
    return watch if watch

    watch = find_by(user: user,
                    watched_type: "Ci",
                    watched_id: outage.cis.map(&:ancestors).flatten)
    return watch if watch

    find_by(user: user, watched_id: outage.id, watched_type: "Outage")
  end
end
