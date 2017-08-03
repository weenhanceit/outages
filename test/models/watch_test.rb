require "test_helper"

class WatchTest < ActiveSupport::TestCase
  test "get a unique outage watch joining user and outage" do
    assert_equal watches(:edit_watching_company_a_outage_watched_by_edit),
      Watch.unique_watch_for(users(:edit_ci_outages),
        outages(:company_a_outage_watched_by_edit))
  end

  test "get a unique CI watch joining user and outage" do
    assert_equal watches(:edit_watching_company_c_ci_001),
      Watch.unique_watch_for(users(:edit_ci_outages_c),
        outages(:company_c_outage_watched_indirectly))
  end

  test "get a unique CI watched three ways" do
    assert_equal watches(:edit_watching_company_c_outage),
      Watch.unique_watch_for(users(:edit_ci_outages_c),
        outages(:company_c_outage_watched_three_ways))
  end
end
