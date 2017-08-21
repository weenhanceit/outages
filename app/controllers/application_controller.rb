class ApplicationController < ActionController::Base
  # require 'lib/user.rb'
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :account_exists!, if: :current_user
  skip_before_action :account_exists!, if: :devise_controller?
  around_action :use_user_time_zone, if: :current_user
  before_action :online_notifications,
    if: :current_user,
    except: [:create, :destroy, :update]

  ##
  # If user doesn't yet have an account, all they can do is create one.
  def account_exists!
    redirect_to new_account_url unless current_account
  end

  ##
  # Get the current user's account.
  def current_account
    current_user.account
  end

  helper_method :current_account

  ##
  # Return the path to the CI show page. It used to
  # return the path to the CI edit page if the current user had CI edit
  # privileges. Otherwise returned the path to the CI show page.
  def edit_or_show_ci_path(id)
    # current_user.can_edit_cis? ? edit_ci_path(id) : ci_path(id)
    ci_path(id)
  end

  helper_method :edit_or_show_ci_path

  ##
  # Return the path to the Outage show page. It used to
  # return the path to the Outage edit page if the current user had Outage edit
  # privileges. Otherwise returned the path to the Outage show page.
  def edit_or_show_outage_path(id)
    # current_user.can_edit_outages? ? edit_outage_path(id) : outage_path(id)
    outage_path(id)
  end

  helper_method :edit_or_show_outage_path

  ##
  # A generic way of responding to errors in controllers so the user sees
  # a 404 Not Found page.
  # See: https://stackoverflow.com/a/4983354/3109926
  def not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  ##
  # Put the current user's on-line notifications in an instance variable of
  # the controller, so it's available to the notification partial.
  def online_notifications
    @online_notifications ||= current_user.outstanding_online_notifications
  end

  ##
  # Run all controllers in the current user's time zone.
  def use_user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
