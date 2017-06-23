require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "fragment filter" do
    sign_in_for_system_tests(users(:basic))
    visit outages_url
    click_link "Grid"

    fill_in "Fragment", with: "Outage B"
    click_button "Refresh"
    within(".outages") do
      assert_text "Outage B", count: 1
      assert_selector "tbody tr", count: 1
    end
  end

  test "of interest filter off and on" do
    flunk
  end

  test "start time and end time" do
    flunk
  end

  test "start time only" do
    flunk
  end

  test "end time only" do
    flunk
  end
end
