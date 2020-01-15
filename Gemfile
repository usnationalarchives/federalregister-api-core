source 'https://rubygems.org'

gem 'rails', '6.0.2.1'

# ==============================================================================
# gems supporting backward-compatibility with Rails 2 conventions:
gem 'rails-observers'
gem 'edge_rider'
# ==============================================================================

gem 'mysql2'
gem 'memoist'

# production app server
gem 'passenger', '~> 6.0'
gem 'nokogiri'
gem 'curb', '0.9.0'
gem 'http_headers', '0.0.2.3'
gem 'geokit', '1.10.0', :require => 'geokit'
gem 'geokit-rails'
gem 'will_paginate', :require => 'will_paginate'
gem 'amatch', '0.2.11'
gem 'indefinite_article'
gem 'titleize' #updates ActiveSupport titleize with stop word support
gem 'rubyzip', '>= 1.1.7'
gem 'zip-zip' # will load compatibility for old rubyzip API.
gem 'fog', '~> 1.3'
gem 'formtastic', "~> 2.1"
gem 'json', '1.8.6'
gem 'ym4r', '0.6.1'
gem 'thinking-sphinx', '~> 4.4.1 ', :require => 'thinking_sphinx'
gem 'ffi-hunspell',
  :git => 'https://github.com/postmodern/ffi-hunspell.git',
  :ref => '91516637fdff9cef9bae66aefdd89e1b4a8b5831',
  :require => 'ffi/hunspell'

gem 'honeybadger', '~> 2.3.3'
gem 'resque-honeybadger',
    :git => 'https://github.com/henrik/resque-honeybadger.git',
    :ref => '832be87662840d44e73f66c006796da8ed6250e2'
gem 'sitemap_generator', '~> 1.5.0'

gem 'paperclip', '~> 2.8'
 # required by paperclip but unspecified version - this ensures a comptible version
gem 'mime-types', '~> 1.25', '>= 1.25.1'
gem 'aws-sdk-v1'
# add methods to the ruby Process command via C-extensions
gem 'proc-wait3'

gem 'stevedore', '0.3.0'

# fork of delynn/userstamp plugin
# gem 'activerecord-userstamp', git: 'https://github.com/criticaljuncture/userstamp', branch: 'rails_six'

gem 'active_hash', '~> 2.0'
gem 'acts_as_list'
# gem 'bcrypt-ruby', '2.1.2', :require => 'bcrypt'
gem 'bcrypt'
gem 'bootstrap-sass', '2.3.2.2'
gem 'authlogic'
gem 'bootsnap'
gem 'jquery-rails'

# wrapper around http requests that supports multiple backends
gem 'faraday'
# make multiple http requests concurrently
gem 'typhoeus', '~> 1.0', '>= 1.0.1'

# This github issue seems to be failing: https://github.com/binarylogic/searchlogic/issues/141
# gem 'searchlogic', '2.4.12'
gem 'icalendar'
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'

gem "amazon-ec2", :require => false
gem 'popen4'

gem "net-scp", '1.1.0'
gem "net-ssh", '2.9.1'

gem "resque"
gem 'redis', '3.3.5'
gem 'resque-throttler',
    git: 'https://github.com/criticaljuncture/resque-throttler.git',
    branch: 'master',
    require: 'resque/throttler'
# gem "resque-retry", '1.5.3'
# gem "resque-scheduler", '4.3.1'

gem "httparty"
gem "httmultiparty", '~> 0.3.13'

gem "recaptcha", "0.3.1", :require => 'recaptcha/rails'
gem 'sendgrid', :git => "https://github.com/criticaljuncture/sendgrid.git", :branch => 'master'
gem 'modularity'

# gem "validation_reflection"#, "0.3.8" #TODO: Address implications of removing this gem as it has gone stale

gem 'rdoc'
gem 'net-sftp'
gem 'diffy'
gem 'cocaine'
gem 'rails_autolink' # autolink removed in Rails 3.1.  This is an extraction of the functionality.

gem 'hoe'

# cron jobs
gem 'whenever', require: false

gem 'app_config', "=1.3.2",
  :git => 'https://github.com/fredwu/app_config.git',
  :branch => :master

gem 'googleauth'
# lock googleauth dependency to compatible version
gem 'addressable', '2.4.0'

gem 'memoist'

gem 'american_date'

# add methods to the ruby Process command via C-extensions
# (tracking memory usage)
# gem 'proc-wait3'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

#needed for rail 2.x (removed in ruby 2+)
# TODO: BB remove after upgrade
# gem 'iconv', '~> 1.0', '>= 1.0.5'

gem 'open_calais'

gem 'uglifier'
gem 'sass-rails'
gem 'xmlrpc'


group :test do
  gem 'factory_girl', '~> 2.5.2'
  gem 'timecop'
  gem 'mock_redis'
  gem 'vcr'
  gem 'fakeweb'
  gem 'ci_reporter', '1.6.3'
  gem 'test-unit', '1.2.3'
end

group :development do
  gem 'rubocop'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'listen' # Used for config.file_watcher
end

group :development, :test do
  gem 'pry'
  gem 'pry-remote'
  gem 'rspec-rails', '~> 3.6'
end
