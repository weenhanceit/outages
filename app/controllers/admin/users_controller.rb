module Admin
  ##
  # Controller for administering users.
  class UsersController < ::UsersController
    before_action :validate_user_privilege

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
      # puts "IN ADMIN EDIT"
      @user = current_account.users.find(params[:id])
    end

    def index
      @account = current_account
    end

    def update
      # puts "IN ADMIN UPDATE"
      @user = current_account.users.find(params[:id])
      @user.update(user_params)
      if Services::SaveUser.call(@user)
        flash.notice = "Preferences saved."
        # Redirect because of this: https://stackoverflow.com/questions/4475380/why-does-the-render-method-change-the-path-for-a-singular-resource-after-an-edit?rq=1
        redirect_to edit_admin_user_path(@user)
      else
        # puts "Admin: @user.errors.full_messages: #{@user.errors.full_messages}"
        logger.warn @user.errors.full_messages
        # Because we're saying on the preference page, we have to load the
        # notifications explicitly.
        online_notifications
        render :edit
      end
    end

    def new
      @account = current_account
      @user = User.create(privilege_account: false,
      privilege_edit_cis: false,
      privilege_edit_outages: false,
      privilege_manage_users: false)
    end

    def resend_invitation
      @user = current_account.users.find(params[:id])
      @user.invite!(current_user)
      flash.now[:notice] = "Invitation sent."
    end

    private

    def validate_user_privilege
      not_found unless current_user.privilege_manage_users?
    end
  end
end
