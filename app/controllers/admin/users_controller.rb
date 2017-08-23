module Admin
  ##
  # Controller for administering users.
  class UsersController < ::UsersController
    def new
      @account = current_account
      @user = User.new(privilege_account: false,
      privilege_edit_cis: false,
      privilege_edit_outages: false,
      privilege_manage_users: false)
    end
  end
end
