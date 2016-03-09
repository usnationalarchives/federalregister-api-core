source 'http://rubygems.org'

gem 'rails',
  :git => 'https://github.com/makandra/rails.git',
  :branch => '2-3-lts'

gem 'mysql', '2.7'

gem "jrails", "0.6.0"

gem 'nokogiri', '1.5.11'
gem 'curb', '0.9.0'
gem 'http_headers', '0.0.2.3'
gem 'geokit', '1.4.1', :require => 'geokit'
gem 'will_paginate', '2.3.14', :require => 'will_paginate'
gem 'fastercsv', '1.4.0'
gem 'amatch', '0.2.11'
gem 'indefinite_article'
gem 'rubyzip', '0.9.1', :require => 'zip/zip'
gem 'fog'
gem 'formtastic', '0.9.8'

gem 'json', '1.7.7'
gem 'ym4r', '0.6.1'

gem 'thinking-sphinx', '1.4.13', :require => 'thinking_sphinx'
gem 'ffi-hunspell', :require => 'ffi/hunspell'

gem 'honeybadger', :require => 'honeybadger/rails'
gem 'resque-honeybadger',
    :git => 'git@github.com:henrik/resque-honeybadger.git',
    :ref => '832be87662840d44e73f66c006796da8ed6250e2'

gem 'aws-s3', '0.6.2', :require => 'aws/s3'

gem 'paperclip', '~> 2.8'
 # required by paperclip but unspecified version - this ensures a comptible version
gem 'mime-types', '~> 1.25', '>= 1.25.1'
gem 'aws-sdk', '~> 1.6.9'

gem 'stevedore', '0.1.0'
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
gem 'klarlack', '0.0.6'
gem 'system_timer', '1.0.0'
gem "amazon-ec2", :require => false
gem 'popen4'

gem "net-scp", '1.1.0'

gem "capistrano", '2.15.4', :require => false
gem "thunder_punch", '0.0.14', :require => false
gem "rvm-capistrano", "~> 1.5.4", :require => false

gem "resque", "1.19.0"

gem "httparty", "0.8.1"
gem "httmultiparty", '~> 0.3.13'

gem "recaptcha", "0.3.1", :require => 'recaptcha/rails'
gem 'sendgrid', :git => "git://github.com/criticaljuncture/sendgrid.git", :branch => 'master'
gem 'modularity', '0.6.1'

gem "validation_reflection", "0.3.8"
gem 'juicer', '1.0.6'

gem 'rdoc'
gem 'net-sftp'
gem 'diffy'
gem 'cocaine'


gem 'hoe'

# bundler requires these gems in all environments
# gem 'nokogiri', '1.4.2'
# gem 'geokit'

group :deployment do
end

group :development do
  gem 'ruby-debug'
  # bundler requires these gems in development
  # gem 'rails-footnotes'
  # gem 'poolparty', '1.6.9'
  # gem "thunder_punch", '0.0.6', :require => false
end

group :test do
  # bundler requires these gems while running tests

  # FIXME: these are still from github...
  gem 'thoughtbot-shoulda', :require => 'shoulda'
  gem 'seanhussey-woulda',  :require => 'woulda'
  gem 'floehopper-mocha',   :require => 'mocha'

  gem 'rails-test-serving', '0.1.4.2', :require => 'rails_test_serving'
  gem 'jgre-monkeyspecdoc', '0.9.5', :require => 'monkeyspecdoc'

  gem 'rspec', '1.3.0', :require => false
  gem 'rspec-rails', '1.3.2', :require => false
  gem 'webrat', '0.7.1'
  gem 'factory_girl', '1.2.4'
  gem 'spork', '0.7.5', :require => false
  gem 'timecop', '0.3.5'
  gem 'vcr'
  gem 'fakeweb'

  gem 'cucumber'
  gem 'mechanize', '1.0.0'

  gem 'ci_reporter', '1.6.3'
end
