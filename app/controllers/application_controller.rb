class ApplicationController < ActionController::Base
  # require 'lib/user.rb'
  protect_from_forgery with: :exception
  around_action :use_user_time_zone, if: :current_user

  def use_user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def current_account
    current_user.account
  end

  helper_method :current_account

  def edit_or_show_ci_path(id)
    current_user.can_edit_cis? ? edit_ci_path(id) : ci_path(id)
  end

  helper_method :edit_or_show_ci_path

  def edit_or_show_outage_path(id)
    current_user.can_edit_outages? ? edit_outage_path(id) : outage_path(id)
  end

  helper_method :edit_or_show_outage_path

  def notifications
    @notifications = current_user.notifications.where(notified: false, notification_type: "online").order(created_at: :desc)
  end
end
