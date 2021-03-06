require 'yaml'
require 'erb'
require 'active_model' # used in settings file

cron_settings = YAML::load(
  ERB.new(
    File.read(
      File.join(File.dirname(__FILE__), 'settings.yml')
    )
  ).result
)[ENV['RAILS_ENV']]['cron']

set :output, lambda { "2>&1 | sed \"s/^/[$(date)] /\" >> #{path}/log/#{log}.log" }

# load container environment
job_type :rake, [
    'cd :path',
    'source /etc/container_environment.sh',
    'rake :task --trace :output',
  ].join(' && ')


########################
# BULK DATA IMPORTS
########################
if cron_settings["import"]
  # Import today's content
  # retries every 5 minutes from 4AM to 9PM EDT every day
  if ENV['RAILS_ENV'] == 'development'
    every "*/5 4-21 * * *" do
      set :log, 'ofr_bulkdata_import'
      rake 'data:daily:development'
    end
  else
    every "*/5 4-21 * * *" do
      set :log, 'ofr_bulkdata_import'
      rake 'data:daily'
    end
  end

  # Expire pages warning of late content at 9AM
  every '0 9 * * 1-5' do
    set  :log, 'late_page_expiration'
    rake 'varnish:expire:pages_warning_of_late_content'
  end
end

if cron_settings["late_content_notifications"]
  # Warn us of late content
  every '0 8 * * 1-5' do
    set  :log, 'late_content'
    rake 'notifications:content:late'
  end

  # Notify OFR/GPO of missing content
  every '0 7,8 * * 1-5' do
    set  :log, 'late_content'
    rake 'notifications:content:missing'
  end
end

########################
# ELASTICSEARCH
########################
# Reindex the entire content (collapsing delta indexes back into main index)
every :sunday, at: '3AM' do
  set :log, 'weekly_es_reindex'
  rake "elasticsearch:reindex_entry_changes"
  rake "elasticsearch:delete_entry_changes"
end


########################
# PUBLIC INSPECTION
########################
if cron_settings["public_inspection"]
  # Import public inspection documents
  # runs every minute from 7AM EDT until 7PM Monday-Friday
  every '* 7-19 * * 1-5' do
    set :log, 'public_inspection_import'
    rake 'content:public_inspection:import_and_deliver'
  end
end

every 1.day, at: '12:01 am' do
  rake 'content:public_inspection:destroy_published_agency_letters'
end


########################
# GPO IMAGE IMPORTS
########################
if cron_settings["gpo_images"]["import_eps"]
  # Download image from FTP and place in private bucket on S3
  # destructive and should only be run in one environment
  every 15.minutes do
    set :log, 'gpo_eps_importer'
    rake 'content:gpo_images:import'
  end
end

if cron_settings["gpo_images"]["convert_eps"]
  # Enqueue background jobs to process any images that are new
  every 5.minutes do
    set :log, 'gpo_eps_converter'
    rake 'content:gpo_images:convert'
  end
end

if cron_settings["gpo_images"]["reprocess_unlinked_gpo_images"]
  every :sunday, at: '3AM' do
    rake 'content:gpo_images:reprocess_unlinked_gpo_images'
  end
end

########################
# REGULATIONS.GOV DATA
########################

if cron_settings["regulations_dot_gov"]["documents"]
  # every 30 minutes from 4AM to 11PM EDT every day
  every "*/30 4-23 * * *" do
    set :log, 'regulations_dot_gov_document_update'
    rake 'content:entries:import:regulations_dot_gov:modified_today'
  end
end

if cron_settings["regulations_dot_gov"]["dockets"]
  # Download docket data
  every 1.day, at: '12:30PM' do
    set :log, 'docket_import'
    rake 'content:dockets:import'
  end

  # Clear the document cache at a time when the regulations.gov jobs
  # above should have all completed
  every 1.day, at: ['10AM', '2PM'] do
    rake 'varnish:expire:everything'
  end
end


#################################
# REGULATIONS.GOV COMMENTS
#################################

if cron_settings["regulations_dot_gov"]["comments"]
  # Refresh the regulations.gov comment form cache
  every 6.hours do
    set :log, 'regulations_dot_gov_comment_cache'
    rake 'regulations_dot_gov:warm_comment_form_cache'
  end
end


#################################
# GOOGLE ANALYTICS PAGE COUNTS
#################################

if cron_settings["google_analytics"]
  # runs every 2 hours at 15 minutes past the hour
  every '15 0,2,4,6,8,10,12,14,16,18,20,22 * * *' do
    set :log, 'google_analytics_api'
    rake 'documents:page_count:update_today'
  end
end
