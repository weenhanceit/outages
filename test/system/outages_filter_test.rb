require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength
  test "fragment filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))
        current_window.maximize

        choose "watching_All"
        fill_in "Fragment", with: "Outage B\n"

        within(".outages-grid") do
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end

        assert_checked_field "watching_All"
        assert_field "Fragment", with: "Outage B"

        within(".outages-grid") do
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 1
        end
      end
    end
  end

  test "of interest filter off and on" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 7, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        choose "watching_Of_interest_to_me"

        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_checked_field "watching_Of_interest_to_me"
        choose "watching_All"
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
        sign_in_for_system_tests(users(:basic))

        visit outages_url
        current_window.maximize

        choose "watching_All"
        assert_no_selector ".spinner", visible: :any
        fill_in "Outages Before", with: "09012017"
          # with: Time.zone.local(2017, 9, 1, 0, 0).to_s(:to_browser_date)
        find("#latest").send_keys :return
        assert_no_selector ".spinner", visible: :any
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
      travel_to Time.zone.local(2017, 8, 17, 10, 17, 21) do
        sign_in_for_system_tests(users(:basic))
        find_field("Outages Before").send_keys :delete
        choose "watching_All"
        within(".outages-grid") do
          assert_text "Outage Watched by Edit", count: 1
          assert_selector "tbody tr", count: 1
        end

        assert_checked_field "watching_All"
        # NOTE: Currently fills in the default date.
        assert_field "Outages Before", with: "2017-08-31"
      end
    end
  end

  test "end time only" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # NOTE: Change 31 to 30 if we change filter to dates.
      travel_to Time.zone.local(2017, 7, 31) do
        sign_in_for_system_tests(users(:basic))

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
        fill_in "Outages Before", with: "08042017"
        assert_no_selector ".spinner", visible: :any
        find_field("Outages After").send_keys :delete
        assert_no_selector ".spinner", visible: :any
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_checked_field "watching_Of_interest_to_me"
        assert_field "Outages After", with: "2017-07-31"
        assert_field "Outages Before", with: "2017-08-04"
      end
    end
  end

  test "calendar views contain same outages as grid" do
    # TODO: These are two outages added for this test.
    # They should be used in other tests as well and
    # made active in the yml file.
    outage = outages(:company_d_outage_overnight_a)
    outage.active = true
    outage.save
    outage = outages(:company_d_outage_overnight_e)
    outage.active = true
    outage.save

    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 5, 31) do
        sign_in_for_system_tests(users(:edit_ci_outages_d))

        # puts Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        fill_in "Outages After", with: "08012017"
          # with: Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        fill_in "Outages Before", with: "08062017"
          # with: Time.zone.local(2017, 8, 6).to_s(:to_browser_date)
        # with: (Time.zone.local(2017, 8, 1) + 2.weeks).to_s(:to_browser_date)
        assert_field "Outages After", with: "2017-08-01"

        # expected_outages = ["Outage C",
        #                     "Outage D",
        #                     "Outage E",
        #                     "Outage Overnight E"]
        # assert_expected_outages expected_outages

        # within(".outages-grid") do
        #   assert_text "Outage C", count: 1
        #   assert_selector "tbody tr", count: 3
        # end
        #--------------------------------------------------------
        the_date = Date.new(2017, 6, 26)
        expected_day = ["Outage Overnight A"]
        expected_4day = ["Outage Overnight A"]
        expected_week = ["Outage Overnight A"]
        expected_month = ["Outage Overnight A",
                          "Outage Overnight A"]
        assert_day_test expected_day,
          expected_4day,
          expected_week,
          expected_month,
          the_date
        #
        #--------------------------------------------------------
        the_date = Date.new(2017, 7, 1)
        expected_day = []
        expected_4day = []
        expected_week = ["Outage Overnight A"]
        expected_month = ["Outage Overnight A",
                          "Outage A",
                          "Outage B",
                          "Outage C",
                          "Outage D",
                          "Outage E",
                          "Outage Overnight E"]
        assert_day_test expected_day,
          expected_4day,
          expected_week,
          expected_month,
          the_date
        #--------------------------------------------------------
        the_date = Date.new(2017, 7, 27)
        expected_day = []
        expected_4day = ["Outage A"]
        expected_week = ["Outage A"]
        expected_month = ["Outage Overnight A",
                          "Outage A",
                          "Outage B",
                          "Outage C",
                          "Outage D",
                          "Outage E",
                          "Outage Overnight E"]

        # outage = outages(:company_d_outage_overnight_e)
        # puts "Outage Overnight E start #{outage.start_time}"
        # puts "Outage Overnight E end #{outage.end_time}"
        assert_day_test expected_day,
          expected_4day,
          expected_week,
          expected_month,
          the_date
        # #--------------------------------------------------------
        the_date = Date.new(2017, 7, 30)
        expected_day = ["Outage A"]
        expected_4day = ["Outage A",
                         "Outage B",
                         "Outage C"]
        expected_week = ["Outage A"]
        expected_month = ["Outage Overnight A",
                          "Outage A",
                          "Outage B",
                          "Outage C",
                          "Outage D",
                          "Outage E",
                          "Outage Overnight E"]
        assert_day_test expected_day,
          expected_4day,
          expected_week,
          expected_month,
          the_date
        # #--------------------------------------------------------
        the_date = Date.new(2017, 7, 31)
        expected_day = ["Outage B"]
        expected_4day = ["Outage B",
                         "Outage C",
                         "Outage D"]
        expected_week = ["Outage B",
                         "Outage C",
                         "Outage D",
                         "Outage E",
                         "Outage Overnight E"]
        expected_month = ["Outage Overnight A",
                          "Outage A",
                          "Outage B",
                          "Outage C",
                          "Outage D",
                          "Outage E",
                          "Outage Overnight E"]
        assert_day_test expected_day,
          expected_4day,
          expected_week,
          expected_month,
          the_date
        # #--------------------------------------------------------
      end
    end
  end

  test "calendar views by earliest date" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 5, 31) do
        sign_in_for_system_tests(users(:edit_ci_outages_d))

        # puts Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        # FIXME: Get rid of these stinkin' U.S. date formats. WTF?
        fill_in "Outages After",
          with: "08012017" # Time.zone.local(2017, 8, 1).to_s(:to_browser_date)
        assert_no_selector ".spinner", visible: :any
        fill_in "Outages Before",
          with: "08142017" # (Time.zone.local(2017, 8, 1) + 2.weeks).to_s(:to_browser_date)
        assert_no_selector ".spinner", visible: :any
        assert_field "Outages After", with: "2017-08-01"
        # assert_text "phil", count: 2
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
        # Above I think was hacking a broken test to work.
        # click_link "Next"
        # puts "After: #{find_field("Outages After").value}"
        # assert_field "Outages After", with: "2017-08-01"
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

        fill_in "Fragment", with: "Outage B\n"
        assert_no_selector ".spinner", visible: :any

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
        sign_in_for_system_tests(users(:basic))

        fill_in "Outages Before", with: "08312017"
          # with: Time.zone.local(2017, 8, 31).to_s(:to_browser_date)
        # sleep 2
        # puts "looking for spinner..."
        # execute_script("console.log('spinner display before assert: ' + $('.spinner').css('display'));")
        assert_no_selector ".spinner", visible: :any
        # execute_script("console.log('spinner display after assert: ' + $('.spinner').css('display'));")
        # n = find(".spinner")
        # puts "n: #{n.inspect}"
        click_link "4-Day"
        within(".outages-grid") do
          assert_text "Outage A", count: 1
          assert_text "Outage B", count: 1
          assert_selector "tbody tr", count: 2
        end

        assert_no_field "Outages Before"
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
        within(".outages-grid") do
          assert_selector "tbody tr", count: 5
          assert_no_text "Outage G"
        end
        assert_no_checked_field "Show Completed Outages"
      end
    end
  end

  private

  def assert_day_test(exp_day, exp_4day, exp_week, exp_month, the_day)
    fill_in "Outages After", with: the_day.strftime("%m%d%Y")
    assert_no_selector ".spinner", visible: :any

    click_link "Day"
    assert_field "Outages After", with: the_day.strftime("%Y-%m-%d")
    assert_expected_outages exp_day, ".test-outages-day"

    click_link "4-Day"
    assert_field "Outages After", with: the_day.strftime("%Y-%m-%d")
    assert_expected_outages exp_4day, ".test-outages-fourday"

    click_link "Week"
    assert_field "Outages After", with: the_day.strftime("%Y-%m-%d")
    assert_expected_outages exp_week, ".test-outages-week"

    click_link "Month"
    # sleep 5
    assert_field "Outages After", with: the_day.strftime("%Y-%m-%d")
    assert_expected_outages exp_month, ".test-outages-month"
    # assert_expected_outages ["Outage Overnight A"], ".test-outages-month"
    # puts body
  end

  def assert_expected_outages(expected, cal_div = "")
    # puts "#{__LINE__}: expected: #{expected.inspect} div: #{cal_div}"
    unless cal_div == ""
      within(cal_div) do
        expected.uniq.each do |o|
          # puts "TP_#{__LINE__} o: #{o} Count: #{expected.count(o)}"
          assert_text o, count: expected.count(o)
        end
      end
    end

    # Check Grid contains expected outages
    within(".outages-grid") do
      expected.uniq.each do |o|
        # puts "TP_#{__LINE__}: Grid: #{o}"
        assert_text o, count: 1
      end
      if expected.uniq.size.zero?
        assert_selector "tbody tr", count: 1
        assert_text "No outages in specified date range", count: 1
      else
        # puts "TP_#{__LINE__} Count: #{expected.uniq.size}"
        assert_selector "tbody tr", count: expected.uniq.size
        # assert_selector "tbody tr", count: 1
      end
    end
  end
end
