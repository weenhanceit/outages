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
    ci_in_filter = Ci.create(account: @account,
                             active: true,
                             name: "ci_in_filter")
    ci_not_in_filter = Ci.create(account: @account,
                                 active: true,
                                 name: "ci_not_in_filter")
    # Assign 1 ci to first in filter outage, the other to the first
    # not in filter outage.
    outages_in_filter[0].cis_outages.create(ci: ci_in_filter)
    outages_not_in_filter[0].cis_outages.create(ci: ci_not_in_filter)

    # Set up watches
    Watch.create(user: @user1, watched: ci_in_filter)
    Watch.create(user: @user2, watched: ci_not_in_filter)

    # Check Filters
    assert_equal outages_in_filter,
      @user1.filter_outages(watching: "Of interest to me")

    assert_equal (outages_in_filter + outages_not_in_filter).sort,
      @user1.filter_outages(watching: "All").sort
  end

  private

  # set_up_test creates a new account, and a new user in that account within
  # with edit ci/outage privileges
  def initialize_account_and_users(account=nil)
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
