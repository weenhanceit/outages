##
# Join CIs to Outages.
class CisOutage < ApplicationRecord
  belongs_to :outage
  belongs_to :ci
end
