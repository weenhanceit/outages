# rubocop:disable Style/StringLiterals, Metrics/LineLength, Style/EmptyLines
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
# Use postgres as the database for Active Record
gem 'pg', "~> 0.18"
gem 'pg_search'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'bootstrap', '~> 4.0.0'
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end
#gem 'popper_js'
gem 'bootstrap_form', git: "https://github.com/lcreid/rails-bootstrap-forms.git", branch: "shadow"
gem 'octicons_helper'

gem 'jquery-ui-rails'

gem "simple_calendar", "~> 2.0", git: "https://github.com/lcreid/simple_calendar.git"
gem 'detect_timezone_rails'
gem "devise"
gem 'devise_invitable'
# Markdown processor:
gem 'redcarpet'
# There is this for rendering Markdown, but I choose to roll my own: gem 'emd'
gem 'sidekiq'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.15.0'
  gem 'capybara-email'
  gem 'capybara-selenium'
  # gem 'selenium-webdriver' We can't use this with vagrant boxes.
  gem "chromedriver-helper"
  # gem 'poltergeist'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem "rails-erd"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Remove when Rails 5.2
gem "minitest", "~> 5.10.3"
