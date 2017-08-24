##
# Subclass the Devise Invitable controller
# to be able to redirect
# to the edit profile path after changing the password.
# See: https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
class InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters, only: [:create, :update]

  def new
    @user = current_account.users.build(invitation_user_defaults)
  end

  protected

  #   def after_update_path_for(_resource)
  #     edit_user_path
  #   end

  def after_invite_path_for(_inviter, _invitee)
    edit_account_path(current_account)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite,
      keys: [
        :account_id,
        :name,
        :notification_periods_before_outage,
        :notification_period_interval,
        :notify_me_before_outage,
        :notify_me_on_note_changes,
        :notify_me_on_outage_complete,
        :notify_me_on_outage_changes,
        :notify_me_on_overdue_outage,
        :preference_email_time,
        :preference_individual_email_notifications,
        :preference_notify_me_by_email,
        :privilege_account,
        :privilege_edit_cis,
        :privilege_edit_outages,
        :privilege_manage_users,
        :time_zone
      ])
  end

  private

  def invitation_user_defaults
    {
      account: current_account,
      notification_periods_before_outage: 1,
      notification_period_interval: "hours",
      notify_me_before_outage: false,
      notify_me_on_note_changes: false,
      notify_me_on_outage_changes: true,
      notify_me_on_outage_complete: true,
      notify_me_on_overdue_outage: false,
      preference_email_time: "8:00",
      preference_individual_email_notifications: false,
      preference_notify_me_by_email: false,
      privilege_account: false,
      privilege_edit_cis: false,
      privilege_edit_outages: false,
      privilege_manage_users: false
    }
  end
end
