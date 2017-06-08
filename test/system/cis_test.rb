require "application_system_test_case"

class CisTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in_for_system_tests(users(:basic))

    visit cis_url

    assert_selector "h1", text: "Services"
  end

  # test "visit the new outage page" do
  #   sign_in_for_system_tests(users(:edit_ci_outages))
  #
  #   visit new_ci_url
  #
  #   assert_selector "h1", text: "New CI"
  # end

  test "create a new CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_ci_url
    assert_selector "h1", text: "New Service"

    assert_difference "Ci.where(account: user.account).size" do
      fill_in "Name", with: "Server 7"
      fill_in "Description", with: "This is the server in the seventh ring of your know where."
      click_on "Save"
    end

    assert_not Ci.where(name: "Server 7").empty?
  end

  test "edit an existing CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_a)
    visit edit_ci_url(ci)

    assert_no_difference "Ci.where(account: user.account).size" do
      fill_in "Name", with: "Not Server A"
      click_on "Save"
    end

    assert_not Ci.where(name: "Not Server A").empty?
  end

  test "delete a CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_a)
    visit edit_ci_url(ci)

    assert_difference "Ci.where(account: user.account).size", -1 do
      click_on "Delete"
    end

    assert Ci.where(name: ci.name).empty?
  end
  #
  # test "" do
  #   flunk
  # end
end
