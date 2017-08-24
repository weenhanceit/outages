##
# Methods for User views.
module UsersHelper
  def url_for_user_form(account, user)
    # puts "controller_name: #{controller_name}"
    if controller_name == "users"
      # puts "returning #{user_path}"
      user_path
    elsif user.persisted?
      # puts "returning #{admin_user_path(user)}"
      admin_user_path(user)
    else
      # puts "returning #{account_admin_users_path(account)}"
      user_invitation_path
    end
  end
end
