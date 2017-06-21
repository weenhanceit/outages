require "application_system_test_case"

##
# Test overall navigation in the application.
# For now, it's used to test the faked `current_user` function.
# This could be removed in the future if the tests start to take
# too long.
class NavigationTest < ApplicationSystemTestCase
  test "sign in as editor" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))

    assert_text "List of Outages"
    assert_link "Can Edit CIs/Outages"
    click_link "Services"
    assert_link "Can Edit CIs/Outages"
  end
end
