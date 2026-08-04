# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # For capybara-email https://github.com/DockYard/capybara-email
  include Capybara::Email::DSL
  include Capybara::Minitest::Assertions

  Capybara.disable_animation = true
  Capybara.default_max_wait_time = 15

  Capybara.register_driver :playwright_remote_chrome_headless do |app|
    Capybara::Playwright::Driver.new(app,
      browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
      channel: :chrome,
      headless: true,
      viewport: { width: 1400, height: 1261 },
      browser_server_endpoint_url: "ws://#{ENV.fetch('PLAYWRIGHT_HOST')}:3000/ws",
    )
  end

  Capybara.register_driver :playwright_remote_chrome do |app|
    Capybara::Playwright::Driver.new(app,
      browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
      channel: :chrome,
      headless: false,
      viewport: { width: 1400, height: 1261 },
      browser_server_endpoint_url: "ws://#{ENV.fetch('PLAYWRIGHT_HOST')}:3000/ws",
    )
  end

  # Debugging tip: Change to `playwright_remote_chrome` (not headless) and then browse to:
  # http://localhost:7900/?autoconnect=1&resize=scale&password=secret. You can watch the fun there.
  driven_by(ENV.fetch("PLAYWRIGHT_DRIVER", :playwright_remote_chrome_headless).to_sym)

  Capybara.server_host = "0.0.0.0"
  Capybara.server_port = ENV.fetch("TEST_APP_PORT", 3000)
  Capybara.app_host = "http://#{ENV.fetch("TEST_APP_HOST", "localhost")}:#{Capybara.server_port}"
  Capybara.server = :puma, { Silent: true }

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
