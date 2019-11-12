# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)
require(File.join(File.dirname(__FILE__), 'config', 'environment'))

require 'rake'
require 'rake/testtask'
require 'rdoc/task'


require 'tasks/rails'
require 'honeybadger/tasks'
require 'resque/tasks'

begin
  require 'thinking_sphinx/tasks'
rescue LoadError
end



# Brandon's new stuff
# puts Rails.application.class.parent_name



# require File.expand_path('../config/application', __FILE__)

# FR2::Application.load_tasks
