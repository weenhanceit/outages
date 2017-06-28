require "application_system_test_case"

class OutagesFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "fragment filter" do
    skip "TODO: Fix this test for the 'grid on every view' model"
    sign_in_for_system_tests(users(:basic))
    visit outages_url
    click_link "Grid"
    choose "watching_All"

    fill_in "Fragment", with: "Outage B"
    click_button "Refresh"
    within(".outages") do
      assert_text "Outage B", count: 1
      assert_selector "tbody tr", count: 1
    end
  end

  test "of interest filter off and on" do
    skip "TODO: Fix this test for the 'grid on every view' model"
    user = sign_in_for_system_tests(users(:basic))

    visit outages_url
    click_link "Grid"

    choose "watching_Of_interest_to_me"
    click_button "Refresh"
    within(".outages") do
      assert_text "Outage A", count: 1
      assert_text "Outage B", count: 1
      assert_selector "tbody tr", count: 2
    end

    choose "watching_All"
    click_button "Refresh"
    within(".outages") do
      assert_text "Outage A", count: 1
      assert_selector "tbody tr", count: 4
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
