module Admin
  ##
  # Controller for administering users.
  class UsersController < ::UsersController
    def destroy
      @user = current_account.users.find(params[:id])
      @user.active = false
      if @user.save
        redirect_to edit_account_path(current_account)
      else
        logger.error "Unable to deactivate user #{user.id} " +
          @user.errors.full_messages
        render :edit
      end
    end

    def edit
      @user = current_account.users.find(params[:id])
    end

    def index
      @account = current_account
    end

    def new
      @account = current_account
      @user = User.new(privilege_account: false,
      privilege_edit_cis: false,
      privilege_edit_outages: false,
      privilege_manage_users: false)
    end
  end
end
