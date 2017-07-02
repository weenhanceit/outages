require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "fragment filter" do
    sign_in_for_system_tests(users(:basic))
    visit outages_url
    current_window.maximize

    choose "watching_All"
    fill_in "Fragment", with: "Outage B"
    fill_in "Outages Before", with: ""
    fill_in "Outages After", with: ""
    click_button "Refresh"

    within(".test-outages-grid") do
      assert_text "Outage B", count: 1
      assert_selector "tbody tr", count: 1
    end
  end

  test "of interest filter off and on" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 10, 17, 21)
      user = sign_in_for_system_tests(users(:basic))

      visit outages_url
      current_window.maximize

      choose "watching_Of_interest_to_me"
      click_button "Refresh"

      within(".test-outages-grid") do
        assert_text "Outage A", count: 1
        assert_text "Outage B", count: 1
        assert_selector "tbody tr", count: 2
      end

      choose "watching_All"
      click_button "Refresh"
      within(".test-outages-grid") do
        assert_text "Outage A", count: 1
        assert_selector "tbody tr", count: 3
      end
    end
  end

  test "start time and end time" do
    skip "TODO: Implement suitable system test on times"
    flunk
  end

  test "start time only" do
    skip "TODO: Implement suitable system test on times"
    flunk
  end

  test "end time only" do
    skip "TODO: Implement suitable system test on times"
    flunk
  end
end
