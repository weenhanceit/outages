class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :go_to_user_home_page

  def go_to_user_home_page
    redirect_to outages_path if current_user
  end
end
