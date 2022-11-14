# frozen_string_literal: true

##
# Free-form text that can be attached to a CI or an outage.
class Note < ApplicationRecord
  include PgSearch::Model
  multisearchable against: %i[note name]

  belongs_to :notable, polymorphic: true
  belongs_to :user

  validates :note, length: { minimum: 1 }

  delegate :account_id, to: :notable
  delegate :name, to: :user

  def pg_search_document_attrs
    attrs = super
    # puts "PgSearchDocument#pg_search_document_attrs: #{attrs.inspect}"
    attrs.merge(account_id: account_id)
  end
end
