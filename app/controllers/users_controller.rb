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

    current_user.update_attributes(user_params)
    if Services::SaveUser.call(current_user)
      flash.notice = "Preferences saved."
      # Redirect because of this: https://stackoverflow.com/questions/4475380/why-does-the-render-method-change-the-path-for-a-singular-resource-after-an-edit?rq=1
      redirect_to edit_user_path
    else
      logger.warn current_user.errors.full_messages
      # Because we're saying on the preference page, we have to load the
      # notifications explicitly.
      online_notifications
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:id,
      :name,
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
