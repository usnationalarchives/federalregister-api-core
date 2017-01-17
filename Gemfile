source 'https://rubygems.org'

gem 'mini_portile', '~> 0.6.2' # required for docker/clean unix install

gem 'rails',
  :git => 'https://github.com/makandra/rails.git',
  :branch => '2-3-lts'

#gem 'mysql', '2.8.1'
gem 'mysql2', '0.2.24'

gem "jrails", "0.6.0"

gem 'nokogiri', '1.6.0'
gem 'curb', '0.9.0'
gem 'http_headers', '0.0.2.3'
gem 'geokit', '1.10.0', :require => 'geokit'
gem 'will_paginate', '2.3.14', :require => 'will_paginate'
gem 'amatch', '0.2.11'
gem 'indefinite_article'
gem 'titleize' #updates ActiveSupport titleize with stop word support

gem 'rubyzip', '>= 1.1.7'
gem 'zip-zip' # will load compatibility for old rubyzip API.

gem 'fog'
gem 'fog-google', '0.1.0'

gem 'formtastic', '0.9.8'

gem 'json', '1.7.7'
gem 'ym4r', '0.6.1'

gem 'thinking-sphinx', '1.5.0', :require => 'thinking_sphinx'
gem 'ffi-hunspell',
  :git => 'https://github.com/postmodern/ffi-hunspell.git',
  :ref => '91516637fdff9cef9bae66aefdd89e1b4a8b5831',
  :require => 'ffi/hunspell'

gem 'honeybadger', :require => 'honeybadger/rails'
gem 'resque-honeybadger',
    :git => 'https://github.com/henrik/resque-honeybadger.git',
    :ref => '832be87662840d44e73f66c006796da8ed6250e2'

gem 'aws-s3', '0.6.2', :require => 'aws/s3'

gem 'paperclip', '~> 2.8'
 # required by paperclip but unspecified version - this ensures a comptible version
gem 'mime-types', '~> 1.25', '>= 1.25.1'
gem 'aws-sdk', '~> 1.6.9'

gem 'stevedore', '0.2.0'

gem 'active_hash', '0.9.5'
gem 'bcrypt-ruby', '2.1.2', :require => 'bcrypt'
gem 'authlogic', '2.1.3'
#gem 'flickraw', '0.9.8', :require => false

# wrapper around http requests that supports multiple backends
gem 'faraday', '~> 0.9.2'
# make multiple http requests concurrently
gem 'typhoeus', '~> 1.0', '>= 1.0.1'

gem 'searchlogic', '2.4.12'
gem 'haml', '3.0.4'
gem 'compass', '0.10.1'
gem 'compass-960-plugin', '0.9.13', :require => false
gem 'lemonade', '0.3.2'
gem 'icalendar'
gem 'pdfkit', '0.5.2'
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'

gem "amazon-ec2", :require => false
gem 'popen4'

gem "net-scp", '1.1.0'
gem "net-ssh", '2.9.1'

gem "capistrano", '2.15.4', :require => false
gem "thunder_punch", '0.1.3', :require => false
gem "rvm-capistrano", "~> 1.5.4", :require => false

gem "resque", "1.20.0"

gem "httparty"
gem "httmultiparty", '~> 0.3.13'

gem "recaptcha", "0.3.1", :require => 'recaptcha/rails'
gem 'sendgrid', :git => "https://github.com/criticaljuncture/sendgrid.git", :branch => 'master'
gem 'modularity', '0.6.1'

gem "validation_reflection", "0.3.8"
gem 'juicer', '1.0.6'

gem 'rdoc'
gem 'net-sftp'
gem 'diffy'
gem 'cocaine'

gem 'hoe'

gem 'app_config', "=1.3.2",
  :git => 'https://github.com/fredwu/app_config.git',
  :branch => :master

# needed when running on ruby 1.8
gem 'system_timer', '1.2.4', :platform => :ruby_18
gem 'fastercsv', '1.4.0', :platform => :ruby_18


gem 'american_date', :platform => :ruby_19

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

group :test do
  gem 'shoulda', '2.10.3'

  gem 'rspec'
  gem 'mocha', '0.9.8'
  gem 'rspec-rails', '1.3.4', :require => false
  gem 'webrat', '0.7.1'
  gem 'factory_girl', '1.2.4'
  gem 'timecop'
  gem 'cucumber'
  gem 'mechanize', '1.0.0'
  gem 'mock_redis'

  gem 'vcr'
  gem 'fakeweb'

  gem 'ci_reporter', '1.6.3'

  gem 'test-unit', '1.2.3', :platform => :ruby_19
end

group :development do
  gem 'passenger', '~> 5.0.10'
  gem 'rubocop'
end

group :development, :test do
  gem 'pry'
end
