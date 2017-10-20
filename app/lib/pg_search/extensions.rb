# frozen_string_literal: true

module PgSearch
  module Extensions
    def self.multisearch(account, tsquery)
      PgSearch.multisearch(tsquery).where(account_id: account.id)
    end
  end
end
