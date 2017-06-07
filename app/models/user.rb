##
# Represents a user.
class User < ApplicationRecord
  belongs_to :account
  has_many :contributors, inverse_of: :user
  has_many :notes, inverse_of: :user
  has_many :watches, inverse_of: :user

  def can_edit_outages?
    privilege_edit_outages
  end

  def can_edit_cis?
    privilege_edit_cis
  end

  ##
  # Used in the prototype. Probably not needed in the near future.
  def user_privilege_text
    name
    # if privilege_account
    #   "Domain Admin"
    # elsif privilege_manage_users
    #   "User Admin (Manager)"
    # elsif (privilege_edit_cis || privilege_edit_outages)
    #   "Can Edit CIs/Outages"
    # else
    #   "Basic User (Read Only)"
    # end
  end
end
