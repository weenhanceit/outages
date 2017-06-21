class PreferencesController < ApplicationController
  def edit
    # puts "IN EDIT"
    @display = "First Time"
    @phil = "Individual e-mails?: #{current_user.preference_individual_email_notifications}"
    @user = current_user
  end

  def update
    @display = preference_params.inspect
    @phil = "Individual e-mails?: #{current_user.preference_individual_email_notifications}"
    @user = current_user

    if current_user.update(preference_params)
      # redirect_to outages_path
    else
      logger.warn current_user.errors.full_messages
      # render :edit
    end
    render :edit
  end

  private

  def preference_params
    params.require(:preference).permit(:id,
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
