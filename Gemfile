source 'https://rubygems.org'

gem 'rails', '~> 6.1'

# ==============================================================================
# gems supporting backward-compatibility with Rails 2 conventions:
gem 'rails-observers'
gem 'edge_rider'
# ==============================================================================

gem 'mysql2'

# production app server
gem 'passenger', '~> 6.0'
gem 'carrierwave', '2.2.2'
gem 'nokogiri'
gem 'curb'
# app wide settings
gem 'config'
gem 'http_headers', '0.0.2.3'
# used by geokit-rails
gem 'geokit', '1.10.0', :require => 'geokit'
# supplies additional geolocation-based scopes for searches
gem 'geokit-rails'

# acquires lat/long coordinates for postal codes provided in search
gem 'geocoder'

# allows handlebars templates to be precompiled and pass CSP
gem 'handlebars_assets'

# log formatting
gem "lograge"
gem "lograge-sql"

gem "request_store"

gem 'will_paginate', :require => 'will_paginate'
gem 'amatch', '0.2.11'
gem 'indefinite_article'
gem 'titleize' #updates ActiveSupport titleize with stop word support
gem 'rubyzip'
gem 'zip-zip' # will load compatibility for old rubyzip API.
gem 'fog-aws'
gem 'formtastic'
gem 'json'
gem 'ym4r', '0.6.1'
gem 'ffi-hunspell'
gem 'honeybadger'

gem 'kt-paperclip'
 # required by paperclip but unspecified version - this ensures a comptible version
gem 'mime-types', '~> 1.25', '>= 1.25.1'
gem 'mimemagic'
# ==============================================================================
# Ruby 3.1 stops including these gems by default:
gem 'matrix'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
# ==============================================================================
gem 'aws-sdk-s3'
gem 'aws-sdk-cloudfront'
gem 'stevedore', '0.3.0'
gem "slack-notifier"

# fork of delynn/userstamp plugin
# gem 'activerecord-userstamp', git: 'https://github.com/criticaljuncture/userstamp', branch: 'rails_six'

gem 'active_hash',
  # Using master branch for Ruby 3 compatibility since 3.1.0 does not have it yet
  git:    "https://github.com/zilkey/active_hash.git",
  branch: "master",
  ref:    "1c95f992af3ec94c07e19846f042e12bd0b11dd1"
gem 'acts_as_list'
gem 'batch-loader' # Minimizes N+1 queries when serializing for ES
gem 'bcrypt'
gem 'bootstrap-sass', '2.3.2.2'
# Used for watermarking PIL documents
gem 'combine_pdf'
gem 'will_paginate-bootstrap', '0.2.5'
gem 'authlogic'
gem 'bootsnap'
gem 'jquery-rails'

gem 'elasticsearch-persistence', '~> 7.0'
# Used by SornXmlParser for extracting SORN details
gem 'saxerator'

# wrapper around http requests that supports multiple backends
gem 'faraday'
# make multiple http requests concurrently
gem 'typhoeus', '~> 1.0', '>= 1.0.1'
gem 'ransack'
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'

gem "amazon-ec2", :require => false
gem 'popen4'

gem "net-scp"
gem "net-ssh"

gem "resque"
gem "redis", "~> 4.5.1" # (4.6 requires unreleased Sidekiq 6.4.1 to avoid pipelining deprecation warnings)
gem 'rexml'
source "https://gems.contribsys.com/" do
  gem 'sidekiq-pro'
end
gem "sidekiq-throttled"

gem "httparty"
gem "httmultiparty", '~> 0.3.13'

gem "recaptcha", "0.3.1", :require => 'recaptcha/rails'
gem 'sendgrid'
gem 'modularity'
gem 'rdoc'
gem 'net-sftp'
gem 'diffy'

gem 'terrapin'
# support timeouts in terrapin
# https://github.com/thoughtbot/terrapin#posix-spawn
gem 'posix-spawn'

gem 'webrick'
gem 'hoe'

# cron jobs
gem 'whenever', require: false

gem 'googleauth'
# lock googleauth dependency to compatible version

gem 'google-apis-analyticsdata_v1beta'
gem 'addressable', '2.6.0'

gem 'memoist'

gem 'american_date'

# add methods to the ruby Process command via C-extensions
# (tracking memory usage)
gem 'proc-wait3'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

gem 'open_calais'

gem 'uglifier'
gem 'sass-rails'
gem 'xmlrpc'
gem 'rinku'

gem 'fast_jsonapi'

group :test do
  gem 'factory_girl', '~> 2.5.2'

  # used by factory sequences, see topic_factory
  gem 'humanize'

  gem 'timecop'
  gem 'mock_redis'
  gem 'vcr'
  gem 'webmock'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'rubocop'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'listen' # Used for config.file_watcher
  gem 'letter_opener_web'
end

group :development, :test do
  gem 'parallel_tests' # parallel rspec
  gem 'pry'
  gem 'pry-remote'
  gem "rspec_junit_formatter" # formatting rspec results for CI
  gem 'rspec-rails'
  gem "turbo_tests" # parallel rspec
end
