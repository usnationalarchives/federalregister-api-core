require 'rubygems'

ENV["RAILS_ENV"] = 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require "shoulda"
require "shoulda/autoload_macros"
require "shoulda/assertions"
require "shoulda/rails"
require "factory_girl"

# Uncomment the next line to use webrat's matchers
require 'webrat/integrations/rspec-rails'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.extend VCR::RSpec::Macros

  config.before(:each) do
    # If this becomes non-performant, the stub can be relocated
    # to individual tests which use redis.
    Redis.stub(:new).and_return(MockRedis.new)
  end
end
