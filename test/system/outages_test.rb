require "application_system_test_case"

class OutagesTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in_for_system_tests(users(:basic))

    visit outages_url

    assert_selector "h1", text: "Outages"
  end

  test "create a new outage" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_outage_url
    assert_selector "h1", text: "New Outage"

    assert_difference "Outage.where(active: true, account: user.account).size" do
      fill_in "Name", with: "Outage 7"
      fill_in "Description", with: "This is the outage in the seventh ring of your know where."
      click_on "Save"
    end

    assert_not Outage.where(active: true, name: "Outage 7").empty?
  end

  test "edit an existing outage" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_a)
    visit edit_outage_url(outage)

    assert_no_difference "Outage.where(account: user.account).size" do
      fill_in "Name", with: "Not Outage A"
      click_on "Save"
    end

    assert_not Outage.where(name: "Not Outage A").empty?
  end

  test "delete an outage" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_a)
    visit edit_outage_url(outage)

    assert_difference "Outage.where(account: user.account).size", -1 do
      click_on "Delete"
    end

    assert Outage.where(name: outage.name, account: user.account).empty?
  end
end
