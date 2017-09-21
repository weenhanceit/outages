ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def mark_all_user_notifications_notified(user)
    user.notifications.each do |n|
      n.notified = true
      n.save
    end
  end

  # Provide a default hash for creating new valid outage
  def outage_defaults
    basename = Time.new.strftime("%M%S%L")
    {
      account: accounts(:company_a),
      active: true,
      causes_loss_of_service: true,
      completed: false,
      description: "A description of Test outage (#{basename})",
      end_time: Time.find_zone("Samoa").now + 26.hours,
      name: "Test Outage (#{basename})",
      start_time: Time.find_zone("Samoa").now + 24.hours
    }
  end
end
