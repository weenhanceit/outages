require "application_system_test_case"

##
# Test overall navigation in the application.
# For now, it's used to test the faked `current_user` function.
# This could be removed in the future if the tests start to take
# too long.
class NavigationTest < ApplicationSystemTestCase
  test "sign in as editor" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    assert_selector ".test-home-page"
    assert_link "Can Edit CIs/Outages"
    click_link "Services"
    assert_link "Can Edit CIs/Outages"
  end

  test "outages view defaulst to last one used" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 6, 28, 23, 17, 21) do
        user = sign_in_for_system_tests(users(:edit_ci_outages))

        assert_selector ".test-home-page"
        click_link "Month"
        assert_text "Previous June 2017 Next"
        click_link "Services"
        assert_text "Load Balancer D"
        click_link "Outages"
        assert_text "Previous June 2017 Next"
        click_link "Grid"
        assert_text "Completed?"
        click_link "Services"
        assert_text "Load Balancer D"
        click_link "Outages"
        assert_text "Completed?"
      end
    end
  end
end
