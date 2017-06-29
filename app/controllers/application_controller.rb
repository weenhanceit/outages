class ApplicationController < ActionController::Base
  # require 'lib/user.rb'
  protect_from_forgery with: :exception
  around_action :use_user_time_zone, if: :current_user
  before_action :online_notifications,
    if: :current_user,
    except: [:create, :destroy, :update]

  ##
  # Run all controllers in the current user's time zone.
  def use_user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  ##
  # Get the current user's account.
  def current_account
    current_user.account
  end

  helper_method :current_account

  ##
  # Return the path to the CI edit page if the current user has CI edit
  # privileges. Otherwise return the path to the CI show page.
  def edit_or_show_ci_path(id)
    current_user.can_edit_cis? ? edit_ci_path(id) : ci_path(id)
  end

  helper_method :edit_or_show_ci_path

  ##
  # Return the path to the Outage edit page if the current user has Outage edit
  # privileges. Otherwise return the path to the Outage show page.
  def edit_or_show_outage_path(id)
    current_user.can_edit_outages? ? edit_outage_path(id) : outage_path(id)
  end

  helper_method :edit_or_show_outage_path

  ##
  # Put the current user's on-line notifications in an instance variable of
  # the controller, so it's available to the notification partial.
  def online_notifications
    @online_notifications ||= current_user.outstanding_online_notifications
  end
end
