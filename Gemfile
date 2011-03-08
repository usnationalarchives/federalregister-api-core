source :gemcutter
source 'http://gems.github.com'

gem 'rails', '2.3.11'
gem 'mysql', '2.7'

gem 'nokogiri', '1.3.2'
gem 'curb', '0.4.4.0'
gem 'geokit', '1.4.1', :require => 'geokit'
gem 'will_paginate', '2.3.14', :require => 'will_paginate'
gem 'fastercsv', '1.4.0'
gem 'amatch', '0.2.3'
gem 'rubyzip', '0.9.1', :require => 'zip/zip'
gem 'formtastic', '0.9.8'

gem 'json'
gem 'ym4r', '0.6.1'

gem 'thinking-sphinx', '1.3.20', :require => 'thinking_sphinx'
gem 'hoptoad_notifier', '2.1.3'
gem 'aws-s3', '0.6.2', :require => 'aws/s3'
gem 'paperclip', '2.3.1.1'
gem 'stevedore', '0.0.1'
gem 'active_hash', '0.7.9'
gem 'bcrypt-ruby', '2.1.2', :require => 'bcrypt'
gem 'authlogic', '2.1.3'
gem 'flickraw', '0.8.1', :require => false
gem 'searchlogic', '2.4.12'
gem 'haml', '3.0.4'
gem 'compass', '0.10.1'
gem 'compass-960-plugin', '0.9.13', :require => false
gem 'lemonade', '0.3.2'
gem 'icalendar'
gem 'klarlack', '0.0.6'
gem 'system_timer', '1.0.0'
gem "amazon-ec2", :require => false

gem "net-scp", '1.0.4'
gem "capistrano", '2.5.19', :require => false
gem "thunder_punch", '0.0.11', :require => false
gem "delayed_job", '2.0.3'

gem "gwt_rpc", "0.0.1"

gem "recaptcha", "0.3.1", :require => 'recaptcha/rails'
gem 'sendgrid', :git => "git://github.com/criticaljuncture/sendgrid.git", :branch => 'master'

# bundler requires these gems in all environments
# gem 'nokogiri', '1.4.2'
# gem 'geokit'

group :deployment do
end

group :development do
  # bundler requires these gems in development
  # gem 'rails-footnotes'
  # gem 'poolparty', '1.6.8'
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
  
  gem 'cucumber', '0.9.2'
  gem 'mechanize', '1.0.0'
  
  gem 'ci_reporter', '1.6.3'
end
