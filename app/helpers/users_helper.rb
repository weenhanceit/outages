##
# Methods for User views.
module UsersHelper
  def url_for_user_form(account, user)
    # puts "WTF controller_path: #{controller_path}"
    s = case controller_path
    when "users"
      # puts "returning #{user_path}"
      user_path
    when "admin/users"
      # puts "returning #{admin_user_path(user)}"
      admin_user_path(user)
    when "invitations"
      # puts "returning #{user_invitation_path}"
      user_invitation_path
    else
      # puts "Can't happen."
    end
    # puts "s: #{s}"
    s
  end
end
