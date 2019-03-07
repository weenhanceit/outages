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

  test "change password ends on right page" do
    sign_in_for_system_tests(users(:basic))
    visit edit_user_path
    click_link "Change Password or Cancel Registration"
    fill_in "Current password", with: "password"
    click_button "Update"
    assert_current_path edit_user_path
  end

  test "user can't change email" do
    user = users(:basic)
    sign_in_for_system_tests(user)
    present_email = user.email
    changed_email = "achange_#{present_email}"
    visit edit_user_path

    element = find_field("Email")
    assert_equal present_email, element.value

    assert_raises Capybara::ReadOnlyElementError do
      fill_in "Email", with: changed_email
    end
  end

  test "user manager  can't change user email" do
    admin = users(:user_admin)
    user = users(:basic)
    sign_in_for_system_tests(admin)
    present_email = user.email
    changed_email = "achange_#{present_email}"

    click_link "Users"
    # visit admin_user_path

    within(".user-#{user.id}") do
      click_link "Edit"
    end
    element = find_field("Email")
    assert_equal present_email, element.value

    assert_raises Capybara::ReadOnlyElementError do
      fill_in "Email", with: changed_email
    end
  end
end
