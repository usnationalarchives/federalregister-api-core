# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "factory_girl"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Rails3UpgradeSpecHelperMethods
  config.include ElasticsearchSpecHelperMethods
  config.include EdocsSpecHelper

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:expect, :should]
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false

  config.before(:each) do
    # If this becomes non-performant, the stub can be relocated
    # to individual tests which use redis.
    allow(Redis).to receive(:new) { MockRedis.new }
    allow_any_instance_of(CacheUtils::Client).to receive(:purge)
  end

  config.before(:suite) do
    OpenSearchMlModelRegistrar.perform
  end

end
