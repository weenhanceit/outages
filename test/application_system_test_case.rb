require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :poltergeist

  # Only show the path of the screenshot on failed test cases.
  ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "simple"

  def sign_in_for_system_tests(user)
    visit root_url
    within('.test-sign-in') { click_link "Sign In" }
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"
    user
  end

  def click_list_item(text)
    find("li", text: text).click
  end
end
