require "application_system_test_case"

class PreferencesTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "save causes error" do
    sign_in_for_system_tests(users(:basic))
    visit edit_user_path
    select "Pacific Time (US & Canada)", from: "Time zone"
    click_button "Save"
    assert_text "Preferences"
  end

  test "save leaves correct URL" do
    sign_in_for_system_tests(users(:basic))
    visit edit_user_path
    click_button "Save"
    assert_current_path edit_user_path
  end
end
