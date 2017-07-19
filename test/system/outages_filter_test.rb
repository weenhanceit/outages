require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "fragment filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))
        current_window.maximize

        choose "watching_All"
        fill_in "Fragment", with: "Outage B"
        click_button "Refresh"

        within(".outages-grid") do
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end

        assert_checked_field "watching_All"
        assert_field "Fragment", with: "Outage B"
        click_button "Refresh"

        within(".outages-grid") do
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end
      end
    end
  end

  test "of interest filter off and on" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to test_now = Time.zone.local(2017, 07, 28, 10, 17, 21) do
        user = sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        choose "watching_Of_interest_to_me"
        click_button "Refresh"

        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_checked_field "watching_Of_interest_to_me"
        choose "watching_All"
        click_button "Refresh"
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_selector "tbody tr", count: 3
        end

        assert_checked_field "watching_All"
      end
    end
  end

  test "start time and end time" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21) do
        user = sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        # within(".outages-grid") do
        #   assert_text "Outage A", count: 1
        #   assert_text "Outage B", count: 1
        #   assert_selector "tbody tr", count: 2
        # end

        choose "watching_All"
        fill_in "Outages Before",
          with: Time.zone.local(2017, 9, 01, 00, 00).to_s(:to_browser_date)
        click_button "Refresh"
        within(".outages-grid") do
          assert_text "Outage Watched by Edit", count: 1
          assert_selector "tbody tr", count: 4
        end

        assert_checked_field "watching_All"
        assert_field "Outages Before", with: "2017-09-01"
      end
    end
  end

  test "start time only" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to test_now = Time.zone.local(2017, 8, 17, 10, 17, 21) do
        user = sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        # within(".outages-grid") do
        #   assert_text "Outage A", count: 1
        #   assert_text "Outage B", count: 1
        #   assert_selector "tbody tr", count: 2
        # end

        choose "watching_All"
        fill_in "Outages Before", with: ""
        # fill_in "Outages After", with: (test_now + 2.weeks).to_s(:browser)
        click_button "Refresh"
        within(".outages-grid") do
          assert_text "Outage Watched by Edit", count: 1
          assert_selector "tbody tr", count: 1
        end

        assert_checked_field "watching_All"
        assert_field "Outages Before", with: ""
      end
    end
  end

  test "end time only" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # NOTE: Change 31 to 30 if we change filter to dates.
      travel_to Time.zone.local(2017, 7, 31) do
        user = sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        assert_checked_field "watching_Of_interest_to_me"

        # NOTE: This appears to be the only test that the default filter is used.
        within(".outages-grid") do
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end

        # o = Outage.find_by(account: Account.find_by(name: "Company D"), name: "Outage A")
        # puts "o.start_time: #{o.start_time}"
        fill_in "Outages After", with: ""
        fill_in "Outages Before", with: "04/08/2017"
        click_button "Refresh"
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_checked_field "watching_Of_interest_to_me"
        assert_field "Outages After", with: ""
        assert_field "Outages Before", with: "2017-08-14"
      end
    end
  end

  test "calendar views by earliest date" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 5, 31) do
        user = sign_in_for_system_tests(users(:edit_ci_outages_d))

        # puts Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        fill_in "Outages After",
          with: Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        fill_in "Outages Before",
          with: (Time.zone.local(2017, 8, 1) + 2.weeks).to_s(:to_browser_date)
        click_button "Refresh"
        assert_field "Outages After", with: "2017-08-01"

        within(".outages-grid") do
          assert_text "Outage C", count: 1
          assert_selector "tbody tr", count: 3
        end

        click_link "Day"
        assert_field "Outages After", with: "2017-08-01"
        within(".test-outages-day") do
          assert_text "Outage C", count: 1
        end
        within(".outages-grid") do
          assert_text "Outage C", count: 1
          assert_selector "tbody tr", count: 1
        end

        click_link "4-Day"
        assert_field "Outages After", with: "2017-08-01"
        within(".test-outages-fourday") do
          assert_text "Outage C", count: 1
          assert_text "Outage D", count: 1
          assert_text "Outage", count: 2
        end

        # o = Outage.find_by(account: Account.find_by(name: "Company D"), name: "Outage B")
        # puts "o.start_time: #{o.start_time}"
        # puts "o.inspect: #{o.inspect}"
        click_link "Week"
        assert_field "Outages After", with: "2017-08-01"
        within(".test-outages-week") do
          assert_text "Outage B", count: 1
          assert_text "Outage C", count: 1
          assert_text "Outage D", count: 1
          assert_text "Outage E", count: 1
          assert_text "Outage", count: 4
        end

        # The week is at the July/August boundary, so push a week into August
        # before we ask for the month view.
        click_link "Next"
        assert_field "Outages After", with: "2017-08-01"
        click_link "Month"
        assert_field "Outages After", with: "2017-08-01"
        within(".test-outages-month") do
          assert_text "Outage B", count: 1
          assert_text "Outage C", count: 1
          assert_text "Outage D", count: 1
          assert_text "Outage E", count: 1
          assert_text "Outage F", count: 1
          assert_text "Outage", count: 5
        end

        click_link "Previous"
        assert_field "Outages After", with: "2017-08-01"
        within(".test-outages-month") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_text "Outage C", count: 1
          assert_text "Outage D", count: 1
          assert_text "Outage E", count: 1
          assert_text "Outage", count: 5
        end
      end
    end
  end

  test "fragment carried through refreshes" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 25, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))
        current_window.maximize

        fill_in "Fragment", with: "Outage B"
        click_button "Refresh"

        # Currently seems to default to month, so this gets one hit.
        within(".outages-grid") do
          assert_selector "tbody tr", count: 1
        end

        click_link "4-Day"

        within(".outages-grid") do
          assert_selector "tbody tr", count: 1
          assert_text "No outages in specified date range"
        end

        click_link "Next"

        within(".outages-grid") do
          assert_text "Outage A", count: 0
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end
        within(".test-outages-fourday") do
          assert_text "Outage A", count: 0
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end
      end
    end
  end

  test "watching carries through refreshes" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 6, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))
        current_window.maximize

        choose "watching_All"
        click_button "Refresh"

        within(".outages-grid") do
          assert_selector "tbody tr", count: 1
          assert_text "No outages in specified date range"
        end
        assert_checked_field "watching_All"

        # puts "Clicking Month..."
        click_link "Month"
        within(".test-outages-month") { assert_text "June 2017" }
        within(".outages-grid") do
          assert_selector "tbody tr", count: 1
          assert_text "No outages in specified date range"
        end
        assert_checked_field "watching_All"

        # puts "Clicking Next..."
        click_link "Next"
        within(".test-outages-month") { assert_text "July 2017" }
        within(".test-outages-month") do
          assert_text "July 2017"
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_text "Outage C", count: 1
        end
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_text "Outage C", count: 1
          assert_selector "tbody tr", count: 3
        end
        assert_checked_field "watching_All"
      end
    end
  end

  test "find outage on end date of filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21) do
        user = sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        fill_in "Outages Before",
          with: Time.zone.local(2017, 3, 31, 00, 00).to_s(:to_browser_date)
        click_button "Refresh"
        click_link "4-Day"
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_field "Outages Before", with: "2017-03-31"
      end
    end
  end

  test "completed filter" do
    # TODO: Make sure this test is good, as Phil saw some possible issues.
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 15, 14, 21) do
        sign_in_for_system_tests(users(:edit_ci_outages_d))
        current_window.maximize

        within(".outages-grid") do
          assert_selector "tbody tr", count: 5
        end

        check "Show Completed Outages"
        click_button "Refresh"

        within(".outages-grid") do
          assert_selector "tbody tr", count: 6
          assert_text "Outage G"
        end
        assert_checked_field "Show Completed Outages"

        # puts "Clicking Month..."
        click_link "Month"
        within(".test-outages-month") { assert_text "July 2017" }
        within(".outages-grid") do
          assert_selector "tbody tr", count: 6
          assert_text "Outage G"
        end
        assert_checked_field "Show Completed Outages"

        uncheck("Show Completed Outages")
        click_button "Refresh"
        within(".outages-grid") do
          assert_selector "tbody tr", count: 5
          assert_no_text "Outage G"
        end
        assert_no_checked_field "Show Completed Outages"
      end
    end
  end
end
