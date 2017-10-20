# frozen_string_literal: true

require "test_helper"

class PgSearchDocumentTest < ActiveSupport::TestCase
  test "retrieve records" do
    Outage.all.each { |x| x.run_callbacks :save }
    assert_not_empty result = PgSearch.multisearch("Outage")
  end

  test "results from one account" do
    Outage.all.each { |x| x.run_callbacks :save }
    assert_not_empty result = PgSearch::Extensions.multisearch(accounts(:company_a), "Outage")
    assert(result.all? { |x| x.searchable.account == accounts(:company_a) })
  end

  test "results from outages, notes, and CIs" do
    Outage.all.each { |x| x.run_callbacks :save }
    Ci.all.each { |x| x.run_callbacks :save }
    Note.all.each { |x| x.run_callbacks :save }

    unique_string = " " + SecureRandom.uuid
    account = accounts(:company_a)
    outage = account.outages.first
    outage.update_attributes!(description: outage.description + unique_string)
    outage_note = outage.notes.create(user: users(:basic), note: unique_string)
    ci = account.cis.first
    ci.update_attributes!(description: ci.description + unique_string)
    ci_note = ci.notes.create(user: users(:basic), note: unique_string)

    assert_not_empty result = PgSearch::Extensions.multisearch(accounts(:company_a), unique_string)
    assert_equal [outage, outage_note, ci, ci_note].to_set, result.map(&:searchable).to_set
    assert_equal 4, result.count
  end

  test "results from name on notes" do
    Note.all.each { |x| x.run_callbacks :save }

    unique_string = " " + SecureRandom.uuid

    note = Note.all.first
    note.user.update_attributes!(name: unique_string)

    assert_not_empty result = PgSearch::Extensions.multisearch(note.user.account, unique_string)
    assert_equal [note].to_set, result.map(&:searchable).to_set
    assert_equal 1, result.count
  end
end
