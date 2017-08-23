require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :poltergeist, screen_size: [1600, 1400]

  # Only show the path of the screenshot on failed test cases.
  ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "simple"

  def click_list_item(text)
    find("li", text: text).click
  end

  def fill_in_registration_page(email = "a@example.com", name = nil)
    fill_in "Email", with: email
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    fill_in "Name", with: name if name
    click_button "Sign up"
    # NOTE: There's a gem to look at e-mail from Capybara tests:
    # NOTE: https://github.com/DockYard/capybara-email
    user = User.find_by(email: email)
    user.confirm
    user.save!
    sign_in_for_system_tests(user)
    assert_text "You must create an account before you can do anything else."
    assert_current_path new_account_path
    user
  end

  def sign_in_for_system_tests(user)
    visit root_url
    within('.test-sign-in') { click_link "Sign In" }
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
    user
  end

  def sign_up_new_user(email = "a@example.com", name = nil)
    visit new_user_registration_path
    fill_in_registration_page(email, name)
  end
end
