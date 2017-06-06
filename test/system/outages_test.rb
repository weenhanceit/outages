require "application_system_test_case"

class OutagesTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in_for_system_tests(users(:basic))

    visit outages_url

    assert_selector "h1", text: "Outages"
  end

  test "visit the new outage page" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_outage_url

    assert_selector "h1", text: "New Outage"
  end
end
