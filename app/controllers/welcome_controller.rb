class WelcomeController < ApplicationController
  before_action :go_to_user_home_page

  def go_to_user_home_page
    redirect_to outages_path if current_user
  end
end
