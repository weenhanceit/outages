require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "fragment filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 10, 17, 21)
      sign_in_for_system_tests(users(:basic))
      visit outages_url
      current_window.maximize

      choose "watching_All"
      fill_in "Fragment", with: "Outage B"
      click_button "Refresh"

      within(".test-outages-grid") do
        assert_text "Outage B", count: 1
        assert_selector "tbody tr", count: 1
      end
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
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21)
      user = sign_in_for_system_tests(users(:basic))

      visit outages_url
      current_window.maximize

      # within(".test-outages-grid") do
      #   assert_text "Outage A", count: 1
      #   assert_text "Outage B", count: 1
      #   assert_selector "tbody tr", count: 2
      # end

      choose "watching_All"
      fill_in "Outages Before", with: Time.zone.local(2017, 9, 01, 00, 00)
      click_button "Refresh"
      within(".test-outages-grid") do
        assert_text "Outage Watched by Edit", count: 1
        assert_selector "tbody tr", count: 4
      end
    end
  end

  test "start time only" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21)
      user = sign_in_for_system_tests(users(:basic))

      visit outages_url
      current_window.maximize

      # within(".test-outages-grid") do
      #   assert_text "Outage A", count: 1
      #   assert_text "Outage B", count: 1
      #   assert_selector "tbody tr", count: 2
      # end

      choose "watching_All"
      fill_in "Outages Before", with: ""
      click_button "Refresh"
      within(".test-outages-grid") do
        assert_text "Outage Watched by Edit", count: 1
        assert_selector "tbody tr", count: 4
      end
    end
  end

  test "end time only" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # NOTE: Change 31 to 30 if we change filter to dates.
      travel_to Time.zone.local(2017, 7, 31)
      user = sign_in_for_system_tests(users(:basic))

      visit outages_url
      current_window.maximize

      assert_checked_field "watching_Of_interest_to_me"

      # NOTE: This appears to be the only test that the default filter is used.
      within(".test-outages-grid") do
        assert_text "Outage B", count: 1
        assert_selector "tbody tr", count: 1
      end

      fill_in "Outages After", with: ""
      click_button "Refresh"
      within(".test-outages-grid") do
        assert_text "Outage A", count: 1
        assert_text "Outage B", count: 1
        assert_selector "tbody tr", count: 2
      end
    end
  end

  test "calendar views by earliest date" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 5, 31)
      user = sign_in_for_system_tests(users(:edit_ci_outages_d))
      visit outages_url
      fill_in "Outages After", with: Time.zone.local(2017, 8, 1)
      click_button "Refresh"

      within(".test-outages-grid") do
        assert_text "Outage C", count: 1
        assert_selector "tbody tr", count: 4
      end

      click_link "Day"
      within(".test-outages-day") do
        assert_text "Outage C", count: 1
      end

      click_link "4 Day"
      within(".test-outages-fourday") do
        assert_text "Outage C", count: 1
        assert_text "Outage D", count: 1
        assert_text "Outage", count: 2
      end

      click_link "Week"
      within(".test-outages-week") do
        assert_text "Outage B", count: 1
        assert_text "Outage C", count: 1
        assert_text "Outage D", count: 1
        assert_text "Outage E", count: 1
        assert_text "Outage", count: 4
      end

      click_link "Month"
      within(".test-outages-month") do
        assert_text "Outage B", count: 1
        assert_text "Outage C", count: 1
        assert_text "Outage D", count: 1
        assert_text "Outage E", count: 1
        assert_text "Outage F", count: 1
        assert_text "Outage", count: 5
      end

      click_link "Previous"
      within(".test-outages-month") do
        assert_text "Outage A", count: 1
        assert_text "Outage B", count: 1
        assert_text "Outage", count: 2
      end
    end
  end
end
