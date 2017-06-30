require "test_helper"

class UserFilterTest < ActiveSupport::TestCase
  test "of interest 1 watched outage out of 2" do
    # initialize_account_and_users
    initialize_account_and_users

    # Set up our outages
    outages_in_filter = []
    outages_not_in_filter = []

    outages_in_filter << Outage.create(account: @account,
                                       active: true,
                                       causes_loss_of_service: true,
                                       completed: false,
                                       end_time: Time.new + 1.day + 1.hour,
                                       name: "outage 1",
                                       start_time: Time.new + 1.day)

    outages_not_in_filter << Outage.create(account: @account,
                                           active: true,
                                           causes_loss_of_service: true,
                                           completed: false,
                                           end_time: Time.new + 2.day + 1.hour,
                                           name: "outage 2",
                                           start_time: Time.new + 2.day)

    # Set up watches
    Watch.create(user: @user1, watched: outages_in_filter[0])
    Watch.create(user: @user2, watched: outages_not_in_filter[0])

    # Check Filters
    assert_equal outages_in_filter,
      @user1.filter_outages(watching: "Of interest to me")

    assert_equal (outages_in_filter + outages_not_in_filter).sort,
      @user1.filter_outages(watching: "All").sort
  end

  test "of interest 1 directly watched ci out of 2" do
    # initialize_account_and_users
    initialize_account_and_users

    # Set up our outages
    outages_in_filter = []
    outages_not_in_filter = []

    outages_in_filter << Outage.create(account: @account,
                                       active: true,
                                       causes_loss_of_service: true,
                                       completed: false,
                                       end_time: Time.new + 1.day + 1.hour,
                                       name: "outage 1",
                                       start_time: Time.new + 1.day)

    outages_not_in_filter << Outage.create(account: @account,
                                           active: true,
                                           causes_loss_of_service: true,
                                           completed: false,
                                           end_time: Time.new + 2.day + 1.hour,
                                           name: "outage 2",
                                           start_time: Time.new + 2.day)

    # Set up 2 cis
    ci_watched_by_user = Ci.create(account: @account,
                                   active: true,
                                   name: "ci_watched_by_user")
    ci_not_watched_by_user = Ci.create(account: @account,
                                       active: true,
                                       name: "ci_not_watched_by_user")
    # Assign 1 ci to first in filter outage, the other to the first
    # not in filter outage.
    outages_in_filter[0].cis_outages.create(ci: ci_watched_by_user)
    outages_not_in_filter[0].cis_outages.create(ci: ci_not_watched_by_user)

    # Set up watches
    Watch.create(user: @user1, watched: ci_watched_by_user)
    Watch.create(user: @user2, watched: ci_not_watched_by_user)

    # Check Filters
    assert_equal outages_in_filter,
      @user1.filter_outages(watching: "Of interest to me")

    assert_equal (outages_in_filter + outages_not_in_filter).sort,
      @user1.filter_outages(watching: "All").sort
  end

  test "of interest 1 indirectly watched ci out of 2" do
    # initialize_account_and_users
    initialize_account_and_users

    # Set up our outages
    outages_in_filter = []
    outages_not_in_filter = []

    outages_in_filter << Outage.create(account: @account,
                                       active: true,
                                       causes_loss_of_service: true,
                                       completed: false,
                                       end_time: Time.new + 1.day + 1.hour,
                                       name: "outage 1",
                                       start_time: Time.new + 1.day)

    outages_not_in_filter << Outage.create(account: @account,
                                           active: true,
                                           causes_loss_of_service: true,
                                           completed: false,
                                           end_time: Time.new + 2.day + 1.hour,
                                           name: "outage 2",
                                           start_time: Time.new + 2.day)

    # Set up 3 cis
    ci_watched_by_user = Ci.create(account: @account,
                                   active: true,
                                   name: "ci_watched_by_user")
    ci_not_watched_by_user = Ci.create(account: @account,
                                       active: true,
                                       name: "ci_not_watched_by_user")
    ci_on_outage = Ci.create(account: @account,
                             active: true,
                             name: "ci_on_outage")

    # Assign 1 ci to first in filter outage, the other to the first
    # not in filter outage.
    outages_in_filter[0].cis_outages.create(ci: ci_on_outage)
    outages_not_in_filter[0].cis_outages.create(ci: ci_not_watched_by_user)

    # Set the outage ci parent to be ci watched
    assert ci_on_outage.parent_links.create(parent: ci_watched_by_user)
    assert ci_watched_by_user.save, ci_watched_by_user.errors.full_messages
    assert ci_on_outage.save, ci_on_outage.errors.full_messages

    # Set up watches
    Watch.create(user: @user1, watched: ci_watched_by_user)
    Watch.create(user: @user2, watched: ci_not_watched_by_user)

    # Check Filters
    assert_equal outages_in_filter,
      @user1.filter_outages(watching: "Of interest to me")

    assert_equal (outages_in_filter + outages_not_in_filter).sort,
      @user1.filter_outages(watching: "All").sort
  end

  test "date range filter" do
    # Test includes times, wrap test in time zone
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      # Set up the earliest and latest dates for our filter
      interval = 10.hours
      earliest = Time.zone.now + 10.days
      latest = earliest + interval
      during = earliest + (interval / 2)
      pre = earliest - 1.hour
      post = latest + 1.hour

      # initialize_account_and_users
      initialize_account_and_users

      # initialize our outages

      outage_pre_post = Outage.create(account: @account,
                                      active: true,
                                      causes_loss_of_service: true,
                                      completed: false,
                                      end_time: post,
                                      name: "outage pre post",
                                      start_time: pre)

       outage_pre_during = Outage.create(account: @account,
                                         active: true,
                                         causes_loss_of_service: true,
                                         completed: false,
                                         end_time: during,
                                         name: "outage pre during",
                                         start_time: pre)

       outage_during_post = Outage.create(account: @account,
                                          active: true,
                                          causes_loss_of_service: true,
                                          completed: false,
                                          end_time: post,
                                          name: "outage during post",
                                          start_time: during)

      outage_earliest_latest = Outage.create(account: @account,
                                             active: true,
                                             causes_loss_of_service: true,
                                             completed: false,
                                             end_time: latest,
                                             name: "outage earliest latest",
                                             start_time: earliest)

      outage_pre_earliest = Outage.create(account: @account,
                                          active: true,
                                          causes_loss_of_service: true,
                                          completed: false,
                                          end_time: earliest,
                                          name: "outage pre latest",
                                          start_time: pre)

      outage_latest_post = Outage.create(account: @account,
                                           active: true,
                                           causes_loss_of_service: true,
                                           completed: false,
                                           end_time: post,
                                           name: "outage latest post",
                                           start_time: latest)

       outage_nil_latest = Outage.create(account: @account,
                                          active: true,
                                          causes_loss_of_service: true,
                                          completed: false,
                                          end_time: latest,
                                          name: "outage nil latest")

       outage_earliest_nil = Outage.create(account: @account,
                                          active: true,
                                          causes_loss_of_service: true,
                                          completed: false,
                                          name: "outage earliest nil",
                                          start_time: earliest)

      # Both Earliest and latest date present
      # Set up array of exepected outages
      outages_in_filter = [outage_pre_post]
      outages_in_filter << outage_pre_during
      outages_in_filter << outage_during_post
      outages_in_filter << outage_earliest_latest
      outages_in_filter << outage_nil_latest
      outages_in_filter << outage_earliest_nil

      actual = @user1.filter_outages(earliest: earliest, latest: latest).sort
      puts "EXPECTED (earliest latest): #{outages_in_filter.map(&:name)}"
      puts "ACTUAL SIZE: #{actual.size}"
      puts "ACTUAL: #{actual.map(&:name)}"
      assert_equal outages_in_filter.sort,
        actual,
        "Unexpected outages from filter with both earliest and latest dates"

      # latest date only, present
      # Set up array of exepected outages
      outages_in_filter = [outage_pre_post]
      outages_in_filter << outage_pre_during
      outages_in_filter << outage_during_post
      outages_in_filter << outage_earliest_latest
      outages_in_filter << outage_pre_earliest
      outages_in_filter << outage_nil_latest
      outages_in_filter << outage_earliest_nil

      puts "EXPECTED (latest only): #{outages_in_filter.map(&:name)}"
      puts "ACTUAL SIZE: #{actual.size}"
      puts "ACTUAL: #{actual.map(&:name)}"
      assert_equal outages_in_filter.sort,
        @user1.filter_outages(earliest: nil, latest: latest).sort,
        "Unexpected outages from filter with only latest date"

      # Earliest date only, present
      # Set up array of exepected outages
      outages_in_filter = [outage_pre_post]
      outages_in_filter << outage_pre_during
      outages_in_filter << outage_during_post
      outages_in_filter << outage_earliest_latest
      outages_in_filter << outage_latest_post
      outages_in_filter << outage_nil_latest
      outages_in_filter << outage_earliest_nil

      puts "EXPECTED (earliest only): #{outages_in_filter.map(&:name)}"
      puts "ACTUAL SIZE: #{actual.size}"
      puts "ACTUAL: #{actual.map(&:name)}"
      assert_equal outages_in_filter.sort,
        @user1.filter_outages(earliest: earliest, latest: nil).sort,
        "Unexpected outages from filter with only earliest date"
    end
    # FIXME: Add outage without start time and outage without end time.
  end

  private

  # set_up_test creates a new account, and a new user in that account within
  # with edit ci/outage privileges
  def initialize_account_and_users(account = nil)
    @account = account ? account : Account.new(name: "This Account test")
    assert @account.save

    @user1 = initialize_user(@account, "A Testor")
    assert @user1.save

    @user2 = initialize_user(@account, "Another Testor")
    assert @user2.save
  end

  def initialize_user(account, name)
    email = "#{name.delete(' ').downcase}@outages.ca"
    User.new(account: account,
             name: name,
             email: email,
             password: "secret",
             notify_me_on_outage_changes: true,
             notify_me_on_outage_complete: false,
             notify_me_before_outage: false,
             notify_me_on_note_changes: false,
             notify_me_on_overdue_outage: false,
             preference_individual_email_notifications: false,
             preference_notify_me_by_email: false,
             privilege_account: false,
             privilege_edit_cis: true,
             privilege_edit_outages: true,
             privilege_manage_users: false)
  end

end
