#############################################################
# RVM Setup
#############################################################
set :rvm_ruby_string, '1.9.3-p551'
set :rvm_require_role, :rvm
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


#############################################################
# General Settings
#############################################################

set :deploy_to,  "/var/www/apps/#{application}"
set :rake, "bundle exec rake"

#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'production'
  set :gateway, 'fr2_production'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "api-core-1.fr2.ec2.internal", "api-core-2.fr2.ec2.internal", "api-core-3.fr2.ec2.internal", "api-core-4.fr2.ec2.internal", "api-core-5.fr2.ec2.internal"
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true} #monster image

  role :rvm, "api-core-1.fr2.ec2.internal", "api-core-2.fr2.ec2.internal", "api-core-3.fr2.ec2.internal", "api-core-4.fr2.ec2.internal", "api-core-5.fr2.ec2.internal", "worker.fr2.ec2.internal", "sphinx.fr2.ec2.internal"

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
  role :app,    "api-core.fr2.ec2.internal"
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  role :rvm, "api-core.fr2.ec2.internal", "sphinx.fr2.ec2.internal", "worker.fr2.ec2.internal", "proxy.fr2.ec2.internal"

  set :github_user_repo, 'criticaljuncture'
  set :github_project_repo, 'federalregister-api-core'
  set :github_username, 'criticaljuncture'
  set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
end

#############################################################
# Set Up for Officialness Environment
#############################################################

task :officialness do
  set :rails_env,  "officialness_staging"
  set :branch, 'officialness'
  set :gateway, 'fr2_officialness'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "api-core.fr2.ec2.internal"
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  role :rvm, "api-core.fr2.ec2.internal", "sphinx.fr2.ec2.internal", "worker.fr2.ec2.internal", "proxy.fr2.ec2.internal"

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
# Bundler
#############################################################
set :excluded_gem_file_groups, [:deployment, :development, :test]


#############################################################
# Honeybadger
#############################################################

set :honeybadger_user, `git config --global github.user`.chomp


#############################################################
# Recipe role setup
#############################################################

set :deploy_roles, [:app, :worker]
set :bundler_roles, [:app, :worker]
set :db_migration_roles, [:worker]
set :sass_roles, [:app, :worker]
set :varnish_roles, [:proxy]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!

after "deploy:update_code",             "bundler:bundle"
after "bundler:bundle",                 "deploy:migrate"
after "deploy:migrate",                 "sass:update_stylesheets"
after "sass:update_stylesheets",        "javascript:combine_and_minify"
after "javascript:combine_and_minify",  "passenger:restart"
after "passenger:restart",              "resque:restart_workers"
after "resque:restart_workers",         "varnish:clear_cache"
after "varnish:clear_cache",            "honeybadger:notify_deploy"


#############################################################
#                                                           #
#                                                           #
#                       Custom Recipes                      #
#                                                           #
#                                                           #
#############################################################

#############################################################
# Get Remote Files
#############################################################

namespace :filesystem do
  task :load_remote do
    run_locally("rsync --verbose  --progress --stats --compress -e 'ssh -p #{port}' --recursive --times --perms --links #{user}@#{domain}:#{deploy_to}/data data")
  end
end

#############################################################
# Restart resque workers
#############################################################

namespace :resque do
  task :restart_workers, :roles => [:worker] do
    sudo "monit -g resque_workers restart"
  end
end


#############################################################
# Pre-asset pipeline asset compilation
#############################################################

namespace :javascript do
  task :combine_and_minify, :roles => [:worker] do
    run "rm #{current_path}/public/javascripts/all.js; cd #{current_path} && bundle exec juicer merge -m closure_compiler -s #{current_path}/public/javascripts/*.js --force -o #{current_path}/tmp/all.js && mv #{current_path}/tmp/all.js #{current_path}/public/javascripts/all.js"
  end
end


# deploy recipes - these should be required last
require 'thunder_punch'
require 'thunder_punch/recipes/apache'
require 'thunder_punch/recipes/honeybadger'
require 'thunder_punch/recipes/passenger'
require 'thunder_punch/recipes/sass'
require 'thunder_punch/recipes/varnish'
