require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :poltergeist

  # Only show the path of the screenshot on failed test cases.
  ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "simple"

  def sign_in_for_system_tests(user)
    current_user = user
  end
end
