require "application_system_test_case"

class TimeZoneTest < ApplicationSystemTestCase
  # test "show user's time zone" do
  #   user = sign_in_for_system_tests(users(:edit_ci_outages))
  #   assert_text user.time_zone
  # end

  test "warn user if browser time zone is different than preference" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    execute_script "delete_cookie('tz');"
    visit root_url
    assert_text user.time_zone
    assert_text "You appear to be in Etc/UTC time zone, " \
                "but your preference is set to Samoa. " \
                "If you want to change to Etc/UTC, " \
                "go to the preferences page."
  end

  test "warn user only once if browser time zone is different than preference" do
    user = sign_in_for_system_tests(users(:edit_ci_outages))
    execute_script "delete_cookie('tz');"
    visit root_url
    assert_text user.time_zone
    assert_text "You appear to be in Etc/UTC time zone, " \
                "but your preference is set to Samoa. " \
                "If you want to change to Etc/UTC, " \
                "go to the preferences page."
    visit cis_path
    assert_no_text "You appear to be in "
  end

  test "don't warn user if browser time zone is the same as preference" do
    user = users(:edit_ci_outages)
    user.time_zone = "UTC"
    user.save!
    sign_in_for_system_tests(user)
    execute_script "delete_cookie('tz');"
    visit root_url
    # assert_text user.time_zone
    assert_no_text "You appear to be in "
  end

  test "user has no time zone -- use browser time zone" do
    user = users(:no_time_zone)
    sign_in_for_system_tests(user)
    execute_script "delete_cookie('tz');"
    visit root_url
    assert_text "Using the Etc/UTC time zone"
  end
end
