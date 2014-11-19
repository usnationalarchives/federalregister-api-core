# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

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

begin
  require 'cucumber'
  require 'cucumber/rake/task'
  
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty"
  end
  task :features => 'db:test:prepare'
rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end

# begin
#   require(File.join(File.dirname(__FILE__), 'config', 'poolparty', 'tasks'))
# rescue LoadError
# end
