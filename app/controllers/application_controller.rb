class ApplicationController < ActionController::Base
  # require 'lib/user.rb'
  protect_from_forgery with: :exception
  before_action :get_privilege

  def get_privilege
    @privilege = "Phil"
  end

  def current_user
    #    return unless session[:user_id]
    @current_user ||=
      User.find_by(name: session[:user_id] || "Basic User (Read Only)" )
  end

  def current_user=(user)
    session[:user_id] = (@current_user = user).name
  end

  helper_method :current_user

  def edit_or_show_ci_path(id)
    current_user.can_edit_cis? ? edit_ci_path(id) : ci_path(id)
  end

  helper_method :edit_or_show_ci_path
end
