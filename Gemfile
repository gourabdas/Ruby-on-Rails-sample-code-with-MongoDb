source "https://rubygems.org"
#source "https://github.com"

gem "rails", "3.2.6"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used for MongoDB
gem "mongoid", "~> 2.4.10"
gem "bson_ext", ">= 1.6.2"

# Gem used for file upload
gem "paperclip", "~> 2.8.0"
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem "aws-sdk",           :require => "aws-sdk"

# Gem used for user authentication
gem "devise", ">= 2.1.2"

# Gems used only for assets and not required
# in production environments by default.
gem "twitter-bootstrap-rails"

group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem "therubyracer", :platforms => :ruby
  gem "uglifier", ">= 1.0.3"
end

# Gem used for jquery
gem "jquery-rails"

# Gem used for subdomain
gem "subdomain-fu", :git => "git://github.com/nhowell/subdomain-fu.git"

# To use pagination
gem "will_paginate_mongoid"
gem "thor", "~> 0.16.0"

# For importing excel data
gem "roo"
gem "axlsx"#, :git => "git://github.com/randym/axlsx.git"

# For mongodb denormalize
gem "mongoid_alize"

gem "tinymce-rails"

#gem "spreadsheet", "0.6.5.8"
#gem "to_xls", :git => "https://github.com/dblock/to_xls.git", :branch => "to-xls-on-models"

gem "bartt-ssl_requirement", "~>1.4.0", :require => "ssl_requirement"

gem "pdfkit"

# Capistrano will add a timestamped Git tag at each deployment, automatically.
gem "capistrano"
gem "capistrano-deploytags"

# Ruby state machines.
gem "aasm"

# Error notification.
gem "exception_notification", :require => "exception_notifier"

# Easily include HighCharts in rails project with this gem
gem "lazy_high_charts"

gem "jquery-datatables-rails", :git => "git://github.com/rweng/jquery-datatables-rails.git"

# All test environment gems are for ruby 1.8.7
group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails", "~>1.7.0"
  gem "annotate", "2.4.0"
  gem "faker"
end

group :test do
  gem "capybara", "1.1.2"
  gem "database_cleaner", "~>0.9.1"
  gem "watchr"
  gem "spork"
  gem "guard-rspec"
  gem "email_spec"
  gem "webrat"
  gem "selenium-webdriver"
  #gem "capybara-webkit", "~>0.7.2"
  #gem "mongoid_session_store", "~>2.0.0"
  #gem "poltergeist", "~>1.0.3"
end

# Currency converter from one currency to another
gem "currency_converter"