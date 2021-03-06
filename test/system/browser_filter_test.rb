require "application_system_test_case"

class BrowserFilterTest < ApplicationSystemTestCase
  # Phil rightly suggested we shouldn't filter the assigned CIs as that could
  # cause a lot of confusion for the user.
  # This test was passing, but the code was removed when this was committed.
  # test "filter assigned cis on existing outage page" do
  #   sign_in_for_system_tests(users(:edit_ci_outages))
  #   outage = outages(:company_a_outage_a)
  #   visit edit_outage_url(outage)
  #
  #   fill_in "Filter Affected Services", with: "a"
  #   within('#js-assigned') do
  #     # Assert the right number first, so we avoid false positives.
  #     # If we check the selectors before the browser has reduced the
  #     # selection, we might have false positives.
  #     assert_selector "li", count: 1
  #     assert_text "Server A"
  #     assert_selector "li", count: 1
  #   end
  #
  #   fill_in "Filter Affected Services", with: "z"
  #   within('#js-assigned') do
  #     assert_no_selector "li"
  #   end
  # end

  test "filter available cis on new outage page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_outage_url

    fill_in "Filter Available Services", with: "l"
    within('#js-available') do
      assert_selector "li", count: 1
      assert_text "Load Balancer D"
    end

    fill_in "Filter Available Services", with: "o"
    within('#js-available') do
      assert_selector "li", count: 2
      assert_text "Load Balancer D"
      assert_text "Router E"
    end

    fill_in "Filter Available Services", with: "ro"
    within('#js-available') do
      assert_selector "li", count: 1
      assert_text "Router E"
    end
  end

  # Phil rightly suggested we shouldn't filter the assigned CIs as that could
  # cause a lot of confusion for the user.
  # Code to make this test succeed was never written.
  # test "filter cis on assigned parents on existing ci page" do
  #   sign_in_for_system_tests(users(:edit_ci_outages))
  #   ci = cis(:company_a_ci_d)
  #   visit edit_ci_url(ci)
  #
  #   fill_in "Filter Dependent Services", with: "b"
  #   within "#test-parents" do
  #     assert_selector "li", count: 1
  #     assert_text "Server B"
  #   end
  #
  #   fill_in "Filter Dependent Services", with: "rv"
  #   within "#test-parents" do
  #     assert_selector "li", count: 2
  #     assert_text "Server B"
  #     assert_text "Server C"
  #   end
  # end

  test "filter cis on available parents on new ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_ci_url

    fill_in "Filter Available Dependents", with: "rv"
    within "#test-parents" do
      assert_selector "li", count: 4
      assert_text "Server A"
      assert_text "Server B"
      assert_text "Server C"
      assert_text "Server F"
    end
  end

  # Phil rightly suggested we shouldn't filter the assigned CIs as that could
  # cause a lot of confusion for the user.
  # Code to make this test succeed was never written.
  # test "filter cis on assigned children on existing ci page" do
  #   sign_in_for_system_tests(users(:edit_ci_outages))
  #   ci = cis(:company_a_ci_d)
  #   visit edit_ci_url(ci)
  #
  #   fill_in "Filter Pre-requisite Services", with: "b"
  #   within "#test-children" do
  #     assert_no_selector "li"
  #   end
  #
  #   fill_in "Filter Pre-requisite Services", with: "T"
  #   within "#test-children" do
  #     assert_selector "li", count: 1
  #     assert_text "Router E"
  #   end
  # end

  test "filter cis on available children on new ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_ci_url

    fill_in "Filter Available Pre-Requisites", with: "cer"
    within "#test-children" do
      assert_selector "li", count: 1
      assert_text "Load Balancer D"
    end
  end
end
