class ApplicationController < ActionController::Base
  # require 'lib/user.rb'
  protect_from_forgery with: :exception

  def current_user
    #    return unless session[:user_id]
    @current_user ||=
      User.find_by(name: session[:user_id] || "Basic User (Read Only)" )
    session[:user_id] = @current_user.name
    # puts "Get current_user: #{@current_user.name} session: #{session[:user_id]}"
    @current_user
  end

  helper_method :current_user

  def current_account
    self.current_user.account
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
