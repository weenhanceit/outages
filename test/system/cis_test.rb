require "application_system_test_case"

class CisTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in_for_system_tests(users(:basic))

    visit cis_url

    assert_selector "h1", text: "Services"
  end

  test "create a new CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_ci_url
    assert_selector "h1", text: "New Service"

    assert_difference "Ci.where(account: user.account).size" do
      fill_in "Name", with: "Server 7"
      fill_in "Description",
        with: "This is the server in the seventh ring of your know where."
      click_on "Save"
    end

    assert_not Ci.where(name: "Server 7").empty?
  end

  test "create a new CI with watch" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_ci_url
    assert_selector "h1", text: "New Service"

    assert_difference "Service.where(account: user.account).size" do
      assert_difference "Watch.count" do
        fill_in "Name", with: "Service 7"
        fill_in "Description",
          with: "This is the watch in the seventh ring of you know where."
        check "Watched"
        click_on "Save"
      end
    end

    assert_not Service.where(name: "Service 7").empty?
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

  test "add a watch on edit page" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_a)
    visit edit_ci_url(ci)
    assert_no_checked_field "Watched"

    assert_no_difference "Ci.where(account: user.account).size" do
      assert_difference "Watch.count" do
        check "Watched"
        click_on "Save"
      end
    end
  end

  test "remove a watch on edit page" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_watched_by_edit)
    visit edit_ci_url(ci)
    assert_checked_field "Watched"

    assert_no_difference "Ci.where(account: user.account).size" do
      assert_difference "Watch.count", -1 do
        uncheck "Watched"
        click_on "Save"
      end
    end
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

  test "Add a dependent service to an existing service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within('#js-prereq-available') { assert_text "Server F" }
    within '#test-parents' do
      click_list_item "Server F"
      click_on "<"
      within('#js-dependent-assigned') { assert_text "Server F" }
    end
    within('#js-prereq-available') { assert_no_text "Server F" }
    assert_difference "CisCi.count" do
      click_on "Save"
    end
    visit edit_ci_url(ci)
    within('#js-dependent-assigned') { assert_text "Server F" }
  end

  test "Remove a dependent service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within('#js-prereq-available') { assert_no_text "Server B" }
    within '#test-parents' do
      click_list_item "Server B"
      click_on ">"
      within('#js-dependent-available') { assert_text "Server B" }
    end
    within('#js-prereq-available') { assert_text "Server B" }
    assert_difference "CisCi.count", -1 do
      click_on "Save"
    end
    visit edit_ci_url(ci)
    within('#js-dependent-available') { assert_text "Server B" }
  end

  test "Add a dependent service to a new service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_ci_url

    fill_in "Name", with: "Test Router"
      within '#test-parents' do
        click_list_item "Server A"
        click_on "<"
        within('#js-dependent-assigned') { assert_text "Server A" }
      end
    assert_difference "CisCi.count" do
      click_on "Save"
    end
  end

  test "Add a dependent service to an existing service then remove it" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within '#test-parents' do
      click_list_item "Server A"
      click_on "<"
      within('#js-dependent-assigned') { assert_text "Server A" }
      click_on ">"
      within('#js-dependent-available') { assert_text "Server A" }
    end
    assert_no_difference "CisCi.count" do
      click_on "Save"
    end
  end

  test "Remove a dependent service and then add it back" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within '#test-parents' do
      click_list_item "Server C"
      click_on ">"
      within('#js-dependent-available') { assert_text "Server C" }
      click_on "<"
      within('#js-dependent-assigned') { assert_text "Server C" }
    end
    assert_no_difference "CisCi.count" do
      click_on "Save"
    end
  end

  test "Add a prerequisite service to an existing service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within('#js-dependent-available') { assert_text "Server F" }
    within '#test-children' do
      click_list_item "Server F"
      click_on "<"
      within('#js-prereq-assigned') { assert_text "Server F" }
    end
    within('#js-dependent-available') { assert_no_text "Server F" }
    assert_difference "CisCi.count" do
      click_on "Save"
    end
    visit edit_ci_url(ci)
    within('#js-prereq-assigned') { assert_text "Server F" }
  end

  test "Remove a prerequisite service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within('#js-dependent-available') { assert_no_text "Router E" }
    within '#test-children' do
      click_list_item "Router E"
      click_on ">"
      within('#js-prereq-available') { assert_text "Router E" }
    end
    within('#js-dependent-available') { assert_text "Router E" }
    assert_difference "CisCi.count", -1 do
      click_on "Save"
    end
    visit edit_ci_url(ci)
    within('#js-prereq-available') { assert_text "Router E" }
  end

  test "Add a prerequisite service to a new service" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_ci_url

    fill_in "Name", with: "Test Router"

    within '#test-children' do
      click_list_item "Server A"
      click_on "<"
      within('#js-prereq-assigned') { assert_text "Server A" }
    end
    assert_difference "CisCi.count" do
      click_on "Save"
    end
  end

  test "Add a prerequisite service to an existing service then remove it" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within '#test-children' do
      click_list_item "Server A"
      click_on "<"
      within('#js-prereq-assigned') { assert_text "Server A" }
      click_on ">"
      within('#js-prereq-available') { assert_text "Server A" }
    end
    assert_no_difference "CisCi.count" do
      click_on "Save"
    end
  end

  test "Remove a prerequisite service and then add it back" do
    sign_in_for_system_tests(users(:edit_ci_outages))

    ci = cis(:company_a_ci_d)
    visit edit_ci_url(ci)

    within '#test-children' do
      click_list_item "Router E"
      click_on ">"
      within('#js-prereq-available') { assert_text "Router E" }
      click_on "<"
      within('#js-prereq-assigned') { assert_text "Router E" }
    end
    assert_no_difference "CisCi.count" do
      click_on "Save"
    end
  end
end
