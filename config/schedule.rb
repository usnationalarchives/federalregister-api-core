require 'yaml'
require 'erb'
require 'active_model' # used in settings file
require 'config'

Config.load_and_set_settings(Config.setting_files('/home/app/config/', ENV['RAILS_ENV']))

set :output, lambda { "2>&1 | sed \"s/^/[$(date)] /\" | tee -a #{path}/log/#{log}.log | logger -t #{log}" }

# load container environment
job_type :rake, [
    'cd :path',
    'source /etc/container_environment.sh',
    'rake :task --trace :output',
  ].join(' && ')


########################
# BULK DATA IMPORTS
########################
if Settings.cron.import
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

if Settings.cron.late_content_notifications
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
# AUTOMATIC MODS REIMPORTING
########################
  # runs every 5th minute from 7AM EDT until 7PM Monday-Friday
  every '*/5 7-19 * * 1-5' do
    set :log, 'automatic_mods_reimporting'
    rake 'content:issues:schedule_auto_import_mods'
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
if Settings.cron.public_inspection
  # Import public inspection documents
  # runs every minute from 8AM EDT until 7PM Monday-Friday
  every '* 8-19 * * 1-5' do
    set :log, 'public_inspection_import'
    rake 'content:public_inspection:import_and_deliver'
  end
end

every 1.day, at: '12:01 am' do
  rake 'content:public_inspection:destroy_published_agency_letters'
end

########################
# 2022 IMAGE PIPELINE
########################
if Settings.cron.images.download_ongoing_images
  # Download image from SFTP and place in image holding tank bucket on S3
  # destructive and should only be run in one environment
  every 5.minutes do
    set :log, 'lock_safe_download_ongoing_images'
    rake 'content:images:lock_safe_download_ongoing_images'
  end
end

if Settings.cron.images.download_historical_images
  # Download image from SFTP (uses alternate credentials) and place in image holding tank bucket on S3
  # destructive and should only be run in one environment
  every 5.minutes do
    set :log, 'lock_safe_download_historical_images'
    rake 'content:images:lock_safe_download_historical_images'
  end
end

if Settings.cron.gpo_images.convert_eps
  every 5.minutes do 
    set :log, 'enqueue_environment_specific_image_downloads'
    rake 'content:images:enqueue_environment_specific_image_downloads'
  end
end

########################
# GPO IMAGE IMPORTS
########################
if Settings.cron.gpo_images.import_eps
  # Download image from SFTP and place in private bucket on S3
  # destructive and should only be run in one environment
  every 15.minutes do
    set :log, 'gpo_eps_importer'
    rake 'content:gpo_images:import'
  end
end

if Settings.cron.gpo_images.convert_eps
  # Enqueue background jobs to process any images that are new
  every 5.minutes do
    set :log, 'gpo_eps_converter'
    rake 'content:gpo_images:convert'
  end
end

if Settings.cron.gpo_images.reprocess_unlinked_gpo_images
  every :sunday, at: '3AM' do
    rake 'content:gpo_images:reprocess_unlinked_gpo_images'
  end
end

########################
# PLACE DETERMINATIONS FOR HISTORICAL IMAGES
########################
every [:sunday, :monday], at: '4:00AM' do
  rake 'data:extract:places_for_historical_documents'
end

########################
# SEMI-ANNUAL UNIFIED AGENDA
########################
every 1.day, at: '3:00PM' do
  rake 'content:regulatory_plans:schedule'
end

########################
# REGULATIONS.GOV DATA
########################

if Settings.cron.regulations_dot_gov.documents
  # every 30 minutes from 4AM to 11PM EDT every day
  every "*/30 4-23 * * *" do
    set :log, 'regulations_dot_gov_document_update'
    rake 'content:entries:import:regulations_dot_gov:modified_today'
  end

  every 1.day, at: '12:01AM' do
    rake 'content:entries:import:regulations_dot_gov:mark_documents_as_closed_for_commenting'
  end
end

if Settings.cron.regulations_dot_gov.dockets
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

if Settings.cron.regulations_dot_gov.comments
  # Refresh the regulations.gov comment form cache
  every 6.hours do
    set :log, 'regulations_dot_gov_comment_cache'
    rake 'regulations_dot_gov:warm_comment_form_cache'
  end
end


#################################
# GOOGLE ANALYTICS PAGE COUNTS
#################################

if Settings.cron.google_analytics
  # runs every 2 hours at 15 minutes past the hour
  every '15 0,2,4,6,8,10,12,14,16,18,20,22 * * *' do
    set :log, 'google_analytics_api'
    rake 'documents:page_count:update_today'
  end
end
