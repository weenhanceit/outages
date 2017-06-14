require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :poltergeist

  # Only show the path of the screenshot on failed test cases.
  ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "simple"

  def sign_in_for_system_tests(user)
    visit root_url
    # puts "F"
    # assert_select "selected_privilege", selected: "Basic User (Read Only)"
    # puts "U"
    # puts "user.name: #{user.name}"
    # puts "C"
    select user.name, from: "selected_privilege"
    # The next line is required to allow the sign-in to happen before the
    # rest of the test case runs.
    assert_text user.name
    # puts "K"
    user
  end

  def click_list_item(text)
    find("li", text: text).click
  end
end
