require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "sign up" do
    visit root_url
    assert_current_path root_path
    current_window.maximize
    click_link "Sign Up"
    fill_in_registration_page
  end

  test "can't navigate to pages while no account" do
    sign_up_new_user
    visit cis_path
    assert_text "You must create an account before you can do anything else."
    assert_current_path new_account_path
  end

  test "add user" do
    sign_up_new_user
    account = create_account
    click_link "Account"
    click_link "Add User"
    assert_current_path new_account_admin_user_path(account)
    fill_in_new_user_page("b.example.com", "Second User")
    assert_difference "account.users.count" do
      click_button "Save"
    end
  end

  test "delete user" do
    flunk
  end

  test "edit user" do
    flunk "Make sure to test fields in both Devise and our preferences"
  end

  test "only admin users can access user pages" do
    flunk
  end
end
