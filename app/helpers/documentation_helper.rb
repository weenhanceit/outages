module DocumentationHelper
  def link_to_admin_users_path_if_logged_in
    link_to_if_logged_in "Users", current_account ? account_admin_users_path(current_account) : nil
  end

  def link_to_new_user_invitation_path_if_logged_in
    link_to_if_logged_in "Add User", current_account ? new_user_invitation_path(current_account) : nil
  end

  def link_to_if_logged_in(name = nil, options = nil, html_options = nil, &block)
    if current_user
      link_to(name, options, html_options, &block)
    else
      name
    end
  end
end
