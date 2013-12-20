require "bundler"
Bundler.setup(:default, :deployment)

# thinking sphinx cap tasks
require 'thinking_sphinx/deploy/capistrano'

# deploy recipes - need to do `sudo gem install thunder_punch` - these should be required last
require 'thunder_punch'

load File.join(File.dirname(__FILE__), '..', 'lib', 'amazon_aws')
set :ec2_config_location, File.join(File.dirname(__FILE__), "amazon.yml")

ec2_config = YAML.load( File.open(ec2_config_location, 'r') )
@ec2 = AmazonAws::EC2.new(ec2_config['access_key_id'], ec2_config['secret_access_key'])

#############################################################
# Set Basics
#############################################################
set :application, "fr2"
set :user, "deploy"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end

# use these settings for making AMIs with thunderpunch
# set :user, "ubuntu"
#ssh_options[:keys] = [File.join('~/Documents/AWS/FR2', "gpoEC2.pem")]


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
  set :gateway, 'federalregister.gov'
  
  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "app-server-1.fr2.ec2.internal", "app-server-2.fr2.ec2.internal", "app-server-3.fr2.ec2.internal", "app-server-4.fr2.ec2.internal", "app-server-5.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true} #monster image
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging" 
  set :branch, `git branch`.match(/\* (.*)/)[1]
  set :gateway, 'fr2.criticaljuncture.org'
  
  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "app-server-1.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}
end


#############################################################
# Database Settings
#############################################################

set :remote_db_name, "fr2_production"
set :db_path,        "#{shared_path}/db"
set :sql_file_path,  "#{shared_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"


#############################################################
# SCM Settings
#############################################################
set :scm,              :git          
set :github_user_repo, 'criticaljuncture'
set :github_project_repo, 'fr2'
set :deploy_via,       :remote_cache
set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
set :github_username, 'criticaljuncture' 


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

after "deploy:update_code",            "symlinks:create"
after "symlinks:create",               "static_files:custom_symlinks"
after "static_files:custom_symlinks",  "deploy:set_rake_path"
after "deploy:set_rake_path",          "bundler:fix_bundle"
after "bundler:fix_bundle",            "deploy:migrate"
after "deploy:migrate",                "sass:update_stylesheets"
after "sass:update_stylesheets",       "javascript:combine_and_minify"
after "javascript:combine_and_minify", "passenger:restart"
after "passenger:restart",             "resque:restart_workers"
after "resque:restart_workers",        "varnish:clear_cache"
after "varnish:clear_cache",           "honeybadger:notify_deploy"


#############################################################
# Symlinks for Static Files
#############################################################
set :custom_symlinks, {
  'config/api_keys.yml'                       => 'config/api_keys.yml',
  'config/mail.yml'                           => 'config/mail.yml',
  'config/newrelic.yml'                       => 'config/newrelic.yml',
  'config/amazon.yml'                         => 'config/amazon.yml',
  'config/initializers/cloudkicker_config.rb' => 'config/cloudkicker_config.rb',
  'config/secrets.yml'                        => 'config/secrets.yml',
  'config/sendgrid.yml'                       => 'config/sendgrid.yml',
  
  # don't symlink data directory directly!
  'data/bulkdata'         => 'data/bulkdata',
  'data/mods'             => 'data/mods',
  'data/regulatory_plans' => 'data/regulatory_plans',
  'data/text'             => 'data/text',
  'data/xml'              => 'data/xml',
  'data/raw'              => 'data/raw',
  'data/entries'          => 'data/entries',
  'data/cfr'              => 'data/cfr',
  'data/dict'             => 'data/dict',
  
  'db/sphinx'       => 'db/sphinx',
}

namespace :static_files do
  task :custom_symlinks, :roles => [:worker]  do
    run "ln -sf #{shared_path}/index #{current_path}/public/"
  end
end


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
  desc "Update api keys"
  task :update_api_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:api_keys.yml #{shared_path}/config/api_keys.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update secret keys"
  task :update_secret_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:secrets.yml #{shared_path}/config/secrets.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update sendgrid keys"
  task :update_sendgrid_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:sendgrid.yml #{shared_path}/config/sendgrid.yml"
    find_and_execute_task("apache:restart")
  end

  desc "Update FR2 aspell dictionaries"
  task :update_aspell_dicts, :roles => [:app, :worker] do
    run "mkdir -p #{shared_path}/data/dict"
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:en_US-fr.rws #{shared_path}/data/dict/en_US-fr.rws"
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:en_US-fr.multi #{shared_path}/data/dict/en_US-fr.multi"
  end
end

#############################################################
# Get Remote Files
#############################################################

namespace :filesystem do
  task :load_remote do
    run_locally("rsync --verbose  --progress --stats --compress -e 'ssh -p #{port}' --recursive --times --perms --links #{user}@#{domain}:#{deploy_to}/shared/data data")
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
