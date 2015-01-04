require "bundler"
Bundler.setup(:default, :deployment)

# thinking sphinx cap tasks
require 'thinking_sphinx/deploy/capistrano'

# deploy recipes - need to do `sudo gem install thunder_punch` - these should be required last
require 'thunder_punch'

# rvm support
set :rvm_ruby_string, 'ree-1.8.7-2012.02'
set :rvm_require_role, :app
set :rvm_type, :system
require "rvm/capistrano/selector_mixed"

#############################################################
# Set Basics
#############################################################
set :application, "federalregister-api-core"
set :user, "deploy"
set :current_path, "/var/www/apps/#{application}"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end


ssh_options[:paranoid] = false
set :use_sudo, true
default_run_options[:pty] = true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }


set :finalize_deploy, false
# we don't need this because we have an asset server
# and we also use varnish as a cache server. Thus
# normalizing timestamps is detrimental.
set :normalize_asset_timestamps, false


set :migrate_target, :current


#############################################################
# General Settings
#############################################################

set :deploy_to,  "/var/www/apps/#{application}"

#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'production'
  set :gateway, 'fr2_production'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "app-server-1.fr2.ec2.internal", "app-server-2.fr2.ec2.internal", "app-server-3.fr2.ec2.internal", "app-server-4.fr2.ec2.internal", "app-server-5.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true} #monster image

  set :github_user_repo, 'usnationalarchives'
  set :github_project_repo, 'federalregister-api-core'
  set :github_username, 'usnationalarchives'
  set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging"
  set :branch, ENV['DEPLOY_BRANCH'] || `git branch`.match(/\* (.*)/)[1]
  set :gateway, 'fr2_staging'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "app-server-1.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  set :github_user_repo, 'criticaljuncture'
  set :github_project_repo, 'federalregister-api-core'
  set :github_username, 'criticaljuncture'
  set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
end


#############################################################
# Database Settings
#############################################################

set :remote_db_name, "fr2_production"
set :db_path,        "#{current_path}/db"
set :sql_file_path,  "#{current_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"


#############################################################
# SCM Settings
#############################################################
set :scm,              :git
set :deploy_via,       :remote_cache

#############################################################
# Git
#############################################################

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :git_enable_submodules, true


#############################################################
# Bundler
#############################################################
# this should list all groups in your Gemfile (except default)
set :gem_file_groups, [:deployment, :development, :test]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!
# all deployment changes that affect app servers also must
# be put in the user-scripts files on s3!!!

after "deploy:update_code",            "bundler:fix_bundle"
after "bundler:fix_bundle",            "deploy:set_rake_path"
after "deploy:set_rake_path",          "deploy:migrate"
after "deploy:migrate",                "sass:update_stylesheets"
after "sass:update_stylesheets",       "javascript:combine_and_minify"
after "javascript:combine_and_minify", "passenger:restart"
after "passenger:restart",             "resque:restart_workers"
after "resque:restart_workers",        "varnish:clear_cache"
after "varnish:clear_cache",           "honeybadger:notify_deploy"

#############################################################
#                                                           #
#                                                           #
#                         Recipes                           #
#                                                           #
#                                                           #
#############################################################


#############################################################
# Restart resque workers
#############################################################

namespace :resque do
  task :restart_workers, :roles => [:worker] do
    sudo "monit -g resque_workers restart"
  end
end


namespace :apache do
  desc "Restart Apache Servers"
  task :restart, :roles => [:app] do
    sudo '/etc/init.d/apache2 restart'
  end
end

namespace :fr2 do
  desc "Update FR2 aspell dictionaries"
  task :update_aspell_dicts, :roles => [:app, :worker] do
    run "mkdir -p #{current_path}/data/dict"
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:en_US-fr.rws #{current_path}/data/dict/en_US-fr.rws"
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:en_US-fr.multi #{current_path}/data/dict/en_US-fr.multi"
  end
end

#############################################################
# Get Remote Files
#############################################################

namespace :filesystem do
  task :load_remote do
    run_locally("rsync --verbose  --progress --stats --compress -e 'ssh -p #{port}' --recursive --times --perms --links #{user}@#{domain}:#{deploy_to}/data data")
  end
end

namespace :javascript do
  task :combine_and_minify, :roles => [:worker] do
    run "rm #{current_path}/public/javascripts/all.js; cd #{current_path} && bundle exec juicer merge -m closure_compiler -s #{current_path}/public/javascripts/*.js --force -o #{current_path}/tmp/all.js && mv #{current_path}/tmp/all.js #{current_path}/public/javascripts/all.js"
  end
end


#############################################################
# Honeybadger Tasks
#############################################################

namespace :honeybadger do
  task :notify_deploy, :roles => [:worker] do
    run "cd #{current_path} && bundle exec rake honeybadger:deploy RAILS_ENV=#{rails_env} TO=#{branch} USER=#{`git config --global github.user`.chomp} REVISION=#{real_revision} REPO=#{repository}"
  end
end
