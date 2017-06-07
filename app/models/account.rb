##
# This is a company, or a department in a company. In general, it groups
# data to be shared by all users in the Account. It's also the entity
# to be billed.
class Account < ApplicationRecord
  has_many :cis, inverse_of: :account
  has_many :outages, inverse_of: :account
  has_many :users, inverse_of: :account
end
