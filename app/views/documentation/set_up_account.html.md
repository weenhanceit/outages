# Setting Up an Account

The first thing you have to do is
sign up
and create an account.
An account might be the entire company,
or it might be one department in a larger organization.
(When Outages is fully released,
the account is what will get billed.)

## Signing Up
When you sign up with the
<%= link_to "Sign Up", new_user_registration_path %>
link,
you become to owner of a new account.
You will be taken to a page
where you enter the account information.
*Note:* that means you don't want to sign up this way
if you just want to join an existing account.
You have to be invited to join an existing account.

## Inviting Users
Once you're created the account,
you can invite other people in your organization
by going to the
<% if current_account %>
<%= link_to "Users", account_admin_users_path(current_account) %>
<% else %>
Users
<% end %>
page
and clicking the "Add User" button,
or by going straight to the
<% if current_account %>
<%= link_to "Add User", new_user_invitation_path(current_account) %>
<% else %>
Add User
<% end %>
page.
