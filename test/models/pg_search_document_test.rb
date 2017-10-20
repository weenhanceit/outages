# frozen_string_literal: true

require "test_helper"

class PgSearchDocumentTest < ActiveSupport::TestCase
  test "retrieve records" do
    Outage.all.each { |x| x.run_callbacks :save }
    assert_not_empty result = PgSearch.multisearch("Outage")
    puts result.count
  end

  test "results from one account" do
    Outage.all.each { |x| x.run_callbacks :save }
    assert_not_empty result = PgSearch::Extensions.multisearch(accounts(:company_a), "Outage")
    # result = result.select { |x| x.searchable.account == accounts(:company_a) }
    assert(result.all? { |x| x.searchable.account == accounts(:company_a) })
  end
end
