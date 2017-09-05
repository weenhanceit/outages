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
    add_user
    assert_text "Users"
  end

  test "delete user" do
    account, user = add_user
    visit account_admin_users_path(account)
    within("fieldset.user-#{user.id}") { click_link "Edit" }
    assert_difference "account.users.count", -1 do
      click_link "Delete"
      assert_current_path edit_account_path(account)
    end
  end

  test "edit user" do
    account, user = add_user
    visit account_admin_users_path(account)
    within("fieldset.user-#{user.id}") { click_link "Edit" }
    fill_in "Name", with: "That's a funny name."
    click_button "Save"
    user.reload
    assert_equal "That's a funny name.", user.name
  end

  test "only user admin users can access user pages" do
    account, _user = add_non_user_admin_user
    visit account_admin_users_path(account)
    assert_text "Routing Error Not Found"
  end

  test "only allow user admins to invite users" do
    add_non_user_admin_user
    visit new_user_invitation_path
    assert_text "Routing Error Not Found"
  end

  test "resend invitation" do
    account, user = add_user
    clear_emails
    click_link "Users"
    edit_user(user)
    click_link "Send Invitation"
    open_email(user.email)
    assert current_email.has_link?("Accept invitation")
  end

  test "no resend button once invitation accepted" do
    skip "This gets an invalid token error, probably because of the host."
    current_window.maximize
    clear_emails
    add_user
    click_link "Sign Out"
    assert_text "Welcome to Outages"
    open_email("b@example.com")
    # puts current_email.body
    # current_email.click_link "Accept invitation"
    # assert_text "babble"
    # fill_in "Password", with: "password"
    # fill_in "Password confirmation", with: "password"
    # click_link "Set my password"
    # click_link "Sign Out"
    sign_in_for_system_tests(@admin_user)
    click_link "Users"
    edit_user(@user)
    assert_no_link "Send Invitation"
  end

  test "Account admin sees all privilege edits" do
    sign_in_for_system_tests(user = users(:domain_admin))
    visit edit_user_path(user)
    assert_checked_field "Manage Account"
    assert_checked_field "Add/Change/Delete Users"
    assert_checked_field "Add/Change/Delete Services"
    assert_checked_field "Add/Change/Delete Outages"
  end

  test "User admin sees all privilege edits except account" do
    sign_in_for_system_tests(user = users(:user_admin))
    visit edit_user_path(user)
    assert_unchecked_field "Manage Account", disabled: true
    assert_checked_field "Add/Change/Delete Users"
    assert_checked_field "Add/Change/Delete Services"
    assert_checked_field "Add/Change/Delete Outages"
  end

  test "Non-admin sees no privilege edits" do
    sign_in_for_system_tests(user = users(:basic))
    visit edit_user_path(user)
    assert_unchecked_field "Manage Account", disabled: true
    assert_unchecked_field "Add/Change/Delete Users", disabled: true
    assert_unchecked_field "Add/Change/Delete Services", disabled: true
    assert_unchecked_field "Add/Change/Delete Outages", disabled: true
  end

  private

  def add_non_user_admin_user
    @user = sign_up_new_user
    @user.privilege_manage_users = false
    @user.save!
    @user.reload
    assert !@user.privilege_manage_users?
    @account = create_account
    assert_no_text "Users"
    [@account, @user]
  end

  def add_user
    @admin_user = sign_up_new_user
    # Rails.logger.debug "*" * 20 + "User signed up."
    # Rails.logger.debug "*" * 20 + "New user can manage users? #{@admin_user.privilege_manage_users?}"
    @account = create_account
    click_link "Account"
    click_link "Add User"
    # Rails.logger.debug "*" * 20 + "Adding other user."
    assert_current_path new_user_invitation_path
    assert_text "Privileges"
    assert_text "Preferences"
    fill_in_new_user_page("b@example.com")
    # Rails.logger.debug "*" * 20 + "Filled in user info."
    assert_difference "@account.users.count" do
      # Rails.logger.debug "*" * 20 + "About to click Save on other user."
      click_button "Save"
      # Rails.logger.debug "*" * 20 + "Clicked Save on other user."
      assert_current_path edit_account_path(@account)
    end
    [@account, @user = User.find_by(email: "b@example.com")]
  end

  ##
  # From the admin user index page, edit a given user.
  def edit_user(user)
    within("fieldset.user-#{user.id}") { click_link "Edit" }
  end
end
