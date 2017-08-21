require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "sign up" do
    visit root_url
    assert_current_path root_path
    current_window.maximize
    click_link "Sign Up"
    fill_in "Email", with: "a@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"
    assert_text "You must create an account before you can do anything else."
    assert_current_path new_account_path
  end

  test "can't navigate to pages while no account" do
    visit new_user_registration_path
    fill_in "Email", with: "a@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"
    visit cis_path
    assert_text "You must create an account before you can do anything else."
    assert_current_path new_account_path
  end
end
