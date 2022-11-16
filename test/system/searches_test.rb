# frozen_string_literal: true

require "application_system_test_case"

class SearchesTest < ApplicationSystemTestCase
  test "fake" do
    Outage.all.each { |x| x.run_callbacks :save }
    Ci.all.each { |x| x.run_callbacks :save }
    Note.all.each { |x| x.run_callbacks :save }

    unique_string = " " + SecureRandom.uuid
    account = accounts(:company_a)
    outage = account.outages.first
    outage.update!(description: outage.description + unique_string)
    outage_note = outage.notes.create(user: users(:basic), note: unique_string)
    ci = account.cis.first
    ci.update!(description: ci.description + unique_string)
    ci_note = ci.notes.create(user: users(:basic), note: unique_string)

    sign_in_for_system_tests(users(:basic))
    current_window.maximize
    fill_in "Search", with: unique_string
    click_on "menu_bar_search_button"
    assert_text "Search Results"
    assert_text unique_string
    assert_selector "li.search-result", count: 4
  end
end
