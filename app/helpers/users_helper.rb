##
# Methods for User views.
module UsersHelper
  def url_for_user_form(account, user)
    if controller_name == "UsersController"
      edit_user_path
    elsif user.persisted?
      edit_admin_user_path(user)
    else
      new_account_admin_user_path(account)
    end
  end
end
