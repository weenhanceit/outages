require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "check notification generated for new outage on watched ci" do
    # Set up the user and outage name to be used in this test
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    outage_name = "Our Test Outage"

    # Create a watch on a Ci,.
    # TODO This should be done using the actual steps a user would follow
    # This shortcut is in place until the functionality is implemented
    ci = cis(:company_a_ci_a)
    puts "notifications_test.rb #{__LINE__}: ci: #{ci.name}"
    ci.watches.create(active: true, user: user)

    # Create and outage and assign our ci to it
    visit new_outage_url
    assert_difference "Outage.where(account: user.account).size" do
      assert_no_difference "Watch.count" do
        fill_in "Name", with: outage_name
        fill_in "Description",
          with: "Outage to generate online notification"
        # click_on "Save"
        click_list_item ci.name
        click_on "<"
        assert_difference "CisOutage.count" do
          click_on "Save"
        end
      end
    end

    # After save we should be on the Outage index page
    # There should be a single notification and the outage name show be listed
    assert_selector "h1", text: "List of Outages of Interest to the User"
    assert_not Outage.where(name: outage_name).empty?
    assert_selector "h2", text: "Notifications"
  end

  test "create a new outage with watch" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_outage_url
    assert_selector "h1", text: "New Outage"

    assert_difference "Outage.where(account: user.account).size" do
      assert_difference "Watch.count" do
        fill_in "Name", with: "Outage 7"
        fill_in "Description",
          with: "This is the outage in the seventh ring of your know where."
        check "Watched"
        click_on "Save"
      end
    end

    assert_not Outage.where(name: "Outage 7").empty?
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

  test "add a watch on edit page" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_a)
    visit edit_outage_url(outage)
    assert_no_checked_field "Watched"

    assert_no_difference "Outage.where(account: user.account).size" do
      assert_difference "Watch.count" do
        check "Watched"
        click_on "Save"
      end
    end
  end

  test "remove a watch on edit page" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_watched_by_edit)
    visit edit_outage_url(outage)
    # TODO: We might have said this should be checked also in the case
    # where watching was via the CI. If so, we need a test case or more
    # go ensure that all works correctly.
    assert_checked_field "Watched"

    assert_no_difference "Outage.where(account: user.account).size" do
      assert_difference "Watch.count", -1 do
        uncheck "Watched"
        click_on "Save"
      end
    end
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

  test "assign a CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_c)
    visit edit_outage_url(outage)

    click_list_item "Server C"
    click_on "<"
    assert_difference "CisOutage.count" do
      click_on "Save"
    end
    visit edit_outage_url(outage)
    within('#js-assigned') { assert_text "Server B" }
  end

  test "assign a CI in a new outage" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    visit new_outage_url

    click_list_item "Server C"
    click_on "<"
    assert_difference "CisOutage.count" do
      click_on "Save"
    end
  end

  test "remove a CI" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_c)
    visit edit_outage_url(outage)

    click_list_item "Server B"
    click_on ">"
    within('#js-available') { assert_text "Server B" }
    assert_difference "CisOutage.count", -1 do
      click_on "Save"
    end
    visit edit_outage_url(outage)
    within('#js-available') { assert_text "Server B" }
  end

  test "remove a CI and then assign it" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_c)
    visit edit_outage_url(outage)

    click_list_item "Server B"
    click_on ">"
    within('#js-available') { assert_text "Server B" }
    click_list_item "Server B"
    click_on "<"
    within('#js-assigned') { assert_text "Server B" }
    assert_no_difference "CisOutage.count" do
      click_on "Save"
    end
  end

  test "remove two CIs at once" do
    skip "I can't figure out how to get this test to select more than one"
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    outage = outages(:company_a_outage_c)
    visit edit_outage_url(outage)

    click_list_item "Server A"
    shift_click_list_item "Server C"
    click_on "<"
    within('#js-assigned') { assert_text "Server A" }
    within('#js-assigned') { assert_text "Server B" }
    within('#js-assigned') { assert_text "Server C" }
    assert_difference "CisOutage.count", 2 do
      click_on "Save"
    end

    visit edit_outage_url(outage)

    click_list_item "Server B"
    shift_click_list_item "Server C"
    click_on ">"
    within('#js-available') { assert_text "Server B" }
    within('#js-available') { assert_text "Server C" }
    assert_difference "CisOutage.count", -2 do
      click_on "Save"
    end
  end

  private

  def shift_click_list_item(text)
    selector = "$('li:contains(\"#{text}\")')"
    # puts "selector: #{selector}"
    execute_script("var ctrlClick = jQuery.Event('mousedown');" \
      "ctrlClick.ctrlKey = true;" \
      "var target = #{selector};" \
      "target.click(ctrlClick);")
  end
end