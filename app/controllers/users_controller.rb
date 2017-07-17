class UsersController < ApplicationController
  def create
    session[:user_id] = params[:selected_privilege] if params[:selected_privilege]
    redirect_to "/outages"
  end

  def destroy
    reset_session
    redirect_to "/outages"
  end

  def edit
    # puts "IN EDIT"
    @user = current_user
  end

  def update
    @user = current_user

    if current_user.update(user_params)
      # redirect_to outages_path
    else
      logger.warn current_user.errors.full_messages
      # render :edit
    end
    # Because we're saying on the preference page, we have to load the
    # notifications explicitly.
    online_notifications
    render :edit
  end

    private

    def user_params
      params.require(:user).permit(:id,
        :notification_periods_before_outage,
        :notification_period_interval,
        :notify_me_before_outage,
        :notify_me_on_note_changes,
        :notify_me_on_overdue_outage,
        :notify_me_on_outage_complete,
        :notify_me_on_outage_changes,
        :preference_email_time,
        :preference_individual_email_notifications,
        :preference_notify_me_by_email,
        :time_zone)
    end
end
