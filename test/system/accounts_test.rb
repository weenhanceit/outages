require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "create account" do
    sign_up_new_user
    create_account
  end

  test "delete account" do
    user = sign_up_new_user
    create_account
    click_link "Account"
    click_link "Delete"
    user.reload
    assert_nil user.account
    # Since delete is just deactivate, test that we can't navigate anywhere.
    # Actually, although we deactivate, we should set all users of the account
    # to not have the account.
    # TODO: Make this test create two users so we test both get deactivated.
  end

  # test "undelete account" do
  #   # Only Phil and Larry should be able to undelete accounts.
  #   flunk
  # end

  test "change account name" do
    sign_up_new_user
    create_account
    click_link "Account"
    fill_in "Name", with: "Tested Account"
    assert_no_difference "Account.count" do
      click_button "Save"
    end
    assert Account.find_by(name: "Tested Account"), "Name wasn't changed"
    assert_current_path user_root_path
  end
end
