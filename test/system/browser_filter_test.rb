require "application_system_test_case"

class BrowserFilterTest < ApplicationSystemTestCase
  test "filter assigned cis on existing outage page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    outage = outages(:company_a_outage_a)
    visit edit_outage_url(outage)

    fill_in "Filter Affected Services", with: "a"
    within('#js-available') do
      assert_selector "li", count: 1
      assert_text "Server A"
      assert_selector "li", count: 1
    end

    fill_in "Filter Affected Services", with: "z"
    within('#js-available') do
      assert_no_selector "li"
    end
  end

  test "filter available cis on new outage page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_outage_url

    fill_in "Filter Available Services", with: "l"
    within('#js-available') do
      assert_text "Load Balancer D"
      assert_selector "li", count: 1
    end

    fill_in "Filter Available Services", with: "o"
    within('#js-available') do
      assert_text "Load Balancer D"
      assert_text "Router E"
      assert_selector "li", count: 2
    end

    fill_in "Filter Available Services", with: "ro"
    within('#js-available') do
      assert_text "Router E"
      assert_selector "li", count: 1
    end
  end

  test "filter cis on assigned parents on existing ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    fill_in "Filter Dependent Services", with: "b"
    within "#test-parents" do
      assert_text "Server B"
      assert_selector "li", count: 1
    end

    fill_in "Filter Dependent Services", with: "rv"
    within "#test-parents" do
      assert_text "Server B"
      assert_text "Server C"
      assert_selector "li", count: 2
    end
  end

  test "filter cis on available parents on new ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_ci_url

    fill_in "Filter Available Dependents", with: "rv"
    within "#test-parents" do
      assert_text "Server A"
      assert_text "Server B"
      assert_text "Server C"
      assert_text "Server F"
      assert_selector "li", count: 4
    end
  end

  test "filter cis on assigned children on existing ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    fill_in "Filter Pre-requisite Services", with: "b"
    within "#test-children" do
      assert_no_selector "li"
    end

    fill_in "Filter Pre-requisite Services", with: "T"
    within "#test-children" do
      assert_text "Router E"
      assert_selector "li", count: 1
    end
  end

  test "filter cis on available children on new ci page" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit new_ci_url

    fill_in "Filter Available Pre-requisites", with: "cer"
    within "#test-children" do
      assert_text "Load Balancer D"
      assert_selector "li", count: 1
    end
  end
end
