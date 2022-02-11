# rubocop:disable Style/StringLiterals, Layout/EmptyLines
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use postgres as the database for Active Record
gem 'pg', "~> 0.18"
gem 'pg_search'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use SCSS for stylesheets
gem 'sassc-rails'
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

gem 'bootsnap'

gem 'bootstrap', '~> 4.0'
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end
# gem 'popper_js'
gem 'bootstrap_form'
gem 'octicons_helper'

gem 'detect_timezone_rails'
gem "devise"
gem 'devise_invitable'
gem 'jquery-ui-rails'

# Markdown processor:
gem 'redcarpet'
# There is this for rendering Markdown, but I choose to roll my own: gem 'emd'
gem 'sidekiq'
gem "simple_calendar", "~> 2.0", git: "https://github.com/lcreid/simple_calendar.git"
gem 'stackprof'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-selenium'
  gem 'webdrivers', '~> 4.0'
end

group :development do
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "rails-erd"
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Remove when Rails 5.2
gem "minitest", "~> 5.10.3"

# rubocop:enable Style/StringLiterals, Layout/EmptyLines
