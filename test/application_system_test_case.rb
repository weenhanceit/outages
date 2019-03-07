# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # For capybara-email https://github.com/DockYard/capybara-email
  include Capybara::Email::DSL

  # The next one is ours, in app/lib
  # Capybara::Session.include CapybaraExtensions::SessionMatchers

  # The docs said do the following, but it borks things big-time:
  # Capybara.app_host = "http://localhost:3000"

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  # driven_by :poltergeist, screen_size: [1600, 1400]

  # Only show the path of the screenshot on failed test cases.
  ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "simple"

  ##
  # Check for a difference in `expression`, but repeat the check until it's
  # true, or two seconds pass. Taken from Rails source and leveraging
  # some Capybara stuff.
  def assert_difference(expression, difference = 1, message = nil, &block)
    expressions = Array(expression)

    exps = expressions.map do |e|
      e.respond_to?(:call) ? e : -> { eval(e, block.binding) }
    end
    before = exps.map(&:call)
    after = []

    retval = yield

    start_time = Capybara::Helpers.monotonic_time
    loop do
      after = exps.map(&:call)
      break if before.zip(after).all? { |(b, a)| a == b + difference } ||
               start_time + 2 < Capybara::Helpers.monotonic_time
      sleep 0.1
    end

    expressions.zip(after).each_with_index do |(code, a), i|
      error  = "#{code.inspect} didn't change by #{difference}"
      error  = "#{message}.\n#{error}" if message
      assert_equal(before[i] + difference, a, error)
    end

    retval
  end

  def click_list_item(text)
    find("li", text: text).click
  end

  def create_account
    fill_in "Name", with: "Test Account"
    assert_difference "Account.count" do
      click_button "Save"
    end
    assert_current_path user_root_path
    Account.find_by(name: "Test Account")
  end

  def fill_in_new_user_page(email = "a@example.com")
    fill_in "Email", with: email
  end

  def fill_in_registration_page(email = "a@example.com", name = nil) # rubocop:disable Metrics/MethodLength
    fill_in_new_user_page(email)
    fill_in "Name", with: name if name
    fill_in "Password (", with: "password"
    fill_in "Password confirmation", with: "password"
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
    within(".test-sign-in") { click_link "Sign In" }
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
