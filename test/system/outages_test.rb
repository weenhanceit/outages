require "application_system_test_case"

class OutagesTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "visiting the index and setting and unsetting a watch" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        sign_in_for_system_tests(users(:basic))

        visit outages_url
        assert_selector ".test-home-page"

        within("tr.test-#{outages(:company_a_outage_a).id}") do
          assert_unchecked_field "watch[active]"
          assert_difference "Watch.count" do
            check "watch[active]"
            assert_checked_field "watch[active]"
            sleep 2
          end
          assert_difference "Watch.count", -1 do
            uncheck "watch[active]"
            assert_unchecked_field "watch[active]"
            sleep 2
          end
        end
      end
    end
  end

  test "create a new outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        visit new_outage_url
        assert_selector "h1", text: "New Outage"

        assert_difference "Outage.where(account: user.account).size" do
          assert_no_difference "Watch.count" do
            fill_in "Name", with: "Outage 7"
            fill_in "Description",
              with: "This is the outage in the seventh ring of your know where."
            click_on "Save"
          end
        end

        assert_not Outage.where(name: "Outage 7").empty?
      end
    end
  end

  test "create a new outage with watch" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        visit new_outage_url
        assert_selector "h1", text: "New Outage"

        assert_difference "Outage.where(account: user.account).size" do
          assert_difference "Watch.count" do
            fill_in "Name", with: "Outage 7"
            fill_in "Description",
              with: "This is the outage in the seventh ring of you know where."
            check "Watched"
            click_on "Save"
          end
        end

        assert_not Outage.where(name: "Outage 7").empty?
      end
    end
  end

  test "edit an existing outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        outage = outages(:company_a_outage_a)
        visit edit_outage_url(outage)

        assert_no_difference "Outage.where(account: user.account).size" do
          fill_in "Name", with: "Not Outage A"
          click_on "Save"
        end

        assert_not Outage.where(name: "Not Outage A").empty?
      end
    end
  end

  test "add a watch on edit page" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
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
    end
  end

  test "remove a watch on edit page" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        outage = outages(:company_a_outage_watched_by_edit)
        visit edit_outage_url(outage)
        assert_checked_field "Watched"

        assert_no_difference "Outage.where(account: user.account).size" do
          assert_difference "Watch.count", -1 do
            uncheck "Watched"
            click_on "Save"
          end
        end
      end
    end
  end

  test "delete an outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))
        outage = outages(:company_a_outage_a)
        visit edit_outage_url(outage)
        assert_difference "Outage.where(account: user.account).size", -1 do
          click_on "Delete"
        end

        assert Outage.where(name: outage.name, account: user.account).empty?
      end
    end
  end

  test "assign a CI" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
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
    end
  end

  test "assign a CI in a new outage" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        visit new_outage_url

        click_list_item "Server C"
        click_on "<"
        assert_difference "CisOutage.count" do
          click_on "Save"
        end
      end
    end
  end

  test "remove a CI" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
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
    end
  end

  test "remove a CI and then assign it" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
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
    end
  end

  test "remove two CIs at once" do
    skip "I can't figure out how to get this test to select more than one"
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 20, 17, 21) do
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
