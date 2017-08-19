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
    assert_current_path user_root_path
  end
end
