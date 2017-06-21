require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "retrieve notification with inactive outage" do
    skip
  end

  test "check notification information methods" do
    notification = notifications(:basic_watching_company_a_ci_a_event_a_online)

    assert_equal "You are watching Service: #{notification.watch.watched.name}",
      notification.reason,
      "Unexpected Reason String"

    assert_equal "New Outage / Changed Outage Info", notification.event_info

    # TODO: fix this test.
    notification = notifications(:watching_company_a_outage_watched_by_edit)

    assert_equal "You are watching Outage: #{notification.watch.watched.name}",
      notification.reason,
      "Unexpected Reason String"
  end
end
