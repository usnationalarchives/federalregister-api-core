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
#ssh_options[:keys] = [File.join('/Users/rburbach/Documents/AWS/FR2', "gpoEC2.pem")]


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
  
  role :proxy, "ec2-184-72-241-172.compute-1.amazonaws.com"
  #role :static, "ec2-184-73-104-122.compute-1.amazonaws.com"
  #role :worker, "ec2-184-73-104-122.compute-1.amazonaws.com", {:primary => true}
  #role :app, *instances
  role :app, "ec2-204-236-209-41.compute-1.amazonaws.com", "ec2-184-72-139-81.compute-1.amazonaws.com", "ec2-174-129-132-251.compute-1.amazonaws.com", "ec2-72-44-36-213.compute-1.amazonaws.com", "ec2-174-129-119-223.compute-1.amazonaws.com", "ec2-204-236-254-83.compute-1.amazonaws.com"
  role :db, "ec2-184-73-60-158.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-184-73-60-158.compute-1.amazonaws.com"
  role :static, "ec2-75-101-243-195.compute-1.amazonaws.com" #monster image
  role :worker, "ec2-75-101-243-195.compute-1.amazonaws.com", {:primary => true} #monster image
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging" 
  set :branch, `git branch`.match(/\* (.*)/)[1]
  
  role :proxy,  "ec2-184-72-250-132.compute-1.amazonaws.com"
  role :app,    "ec2-50-19-14-105.compute-1.amazonaws.com"
  role :db,     "ec2-50-17-145-38.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-50-17-145-38.compute-1.amazonaws.com"
  role :static, "ec2-184-72-163-77.compute-1.amazonaws.com"
  role :worker, "ec2-184-72-163-77.compute-1.amazonaws.com", {:primary => true}
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
after "symlinks:create",               "deploy:set_rake_path"
after "deploy:set_rake_path",          "bundler:fix_bundle"
after "bundler:fix_bundle",            "deploy:migrate"
after "deploy:migrate",                "sass:update_stylesheets"
after "sass:update_stylesheets",       "javascript:combine_and_minify"
after "javascript:combine_and_minify", "passenger:restart"
after "passenger:restart",             "varnish:clear_cache"
after "varnish:clear_cache",           "deploy:notify_hoptoad"


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
  
  'db/sphinx'       => 'db/sphinx',
}


#############################################################
#                                                           #
#                                                           #
#                         Recipes                           #
#                                                           #
#                                                           #
#############################################################


#############################################################
# Transfer raw files to sphinx server
#############################################################

namespace :sphinx do
  task :rebuild_remote_index do
    transfer_raw_files
    find_and_execute_task('thinking_sphinx:configure')
    transfer_sphinx_config
    run_sphinx_indexer
  end
  
  task :rebuild_delta_index do
    transfer_raw_files
    run_sphinx_delta_indexer
  end
  
  task :transfer_raw_files, :roles => [:worker] do
    run "rsync --verbose  --progress --stats --compress --recursive --times --perms --links #{shared_path}/data/raw sphinx:#{shared_path}/data"
  end
  task :transfer_sphinx_config, :roles => [:worker] do
    run "rsync --verbose  --progress --stats --compress --recursive --times --perms --links #{current_path}/config/#{rails_env}.sphinx.conf sphinx:#{shared_path}/config/"
  end
  task :run_sphinx_indexer, :roles => [:sphinx] do
    run "indexer --config #{shared_path}/config/#{rails_env}.sphinx.conf --all --rotate"
  end
  task :run_sphinx_delta_indexer, :roles => [:sphinx] do
    run "indexer --config #{shared_path}/config/#{rails_env}.sphinx.conf --rotate #{delta_index_names}"
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
  task :combine_and_minify, :roles => [:static] do
    run "rm #{current_path}/public/javascripts/all.js; juicer merge -s #{current_path}/public/javascripts/*.js --force -o #{current_path}/tmp/all.js && mv #{current_path}/tmp/all.js #{current_path}/public/javascripts/all.js"
  end
end


######################################################################
# Define out own hoptoad notify so we can specify the server to be run on
######################################################################
namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true }, :roles => [:worker] do
    rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']
    executable = RUBY_PLATFORM.downcase.include?('mswin') ? fetch(:rake, 'rake.bat') : fetch(:rake, 'rake')
    notify_command = "#{executable} hoptoad:deploy TO=#{rails_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
    notify_command << " DRY_RUN=true" if dry_run
    notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
    puts "Notifying Hoptoad of Deploy (#{notify_command})"
    run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} #{notify_command}"
    puts "Hoptoad Notification Complete."
  end
end

