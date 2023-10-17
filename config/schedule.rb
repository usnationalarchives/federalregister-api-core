require 'yaml'
require 'erb'
require 'active_model' # used in settings file
require 'config'

Config.load_and_set_settings(
  Config.setting_files('/home/app/config/', ENV['RAILS_ENV'])
)

# we're assuming json output and prepending two keys, cron and job name
set :output, lambda { "2>&1 | sed 's/^{/{\"cron\":true,\"job\":\"#{job}\",/' | logger" }

# load container environment
job_type :rake, [
    'cd :path',
    'source /etc/container_environment.sh',
    'rake :task --trace :output',
  ].join(' && ')


################################################
# BULK DATA IMPORTS
################################################

if Settings.app.import.content
  # Import today's content
  # retries every 5 minutes from 4AM to 9PM EDT every day
  if ENV['RAILS_ENV'] == 'development'
    every "*/5 4-21 * * *" do
      set :job, 'ofr_bulkdata_import'
      rake 'data:daily:development'
    end
  else
    every "*/5 4-21 * * *" do
      set :job, 'ofr_bulkdata_import'
      rake 'data:daily'
    end
  end

  # Expire pages warning of late content at 9AM
  every '0 9 * * 1-5' do
    set :job, 'late_page_expiration'
    rake 'varnish:expire:pages_warning_of_late_content'
  end
end

if Settings.app.deliver_late_content_notifications
  # Warn us of late content
  every '4,19,34,49 8-11 * * 1-5' do
    set :job, 'late_content'
    rake 'notifications:content:late'
  end

  # Notify OFR/GPO of missing content
  every '0 7,8 * * 1-5' do
    set  :job, 'late_content'
    rake 'notifications:content:missing'
  end
end

################################################
# AUTOMATIC MODS REIMPORTING
################################################

if Settings.app.import.content
  # runs every 5th minute from 7AM EDT until 7PM Monday-Friday
  every '*/5 7-19 * * 1-5' do
    set :job, 'automatic_mods_reimporting'
    rake 'content:issues:enqueue_reimports_of_current_issue'
  end
end

################################################
# AUTOMATIC REIMPORT OF CHANGED ISSUES
################################################

if Settings.app.import.content
  every 1.day, at: '2:00 pm' do
    set :job, 'enqueue_reimports_of_modified_issues'
    # NOTE: Turn back once queues can better support de-prioritized historical reprocessings
    # rake 'content:issues:enqueue_reimports_of_modified_issues'
  end
end

################################################
# ELASTICSEARCH
################################################

if Settings.elasticsearch.enabled && Settings.app.import.content
  # Reindex the entire content (collapsing delta indexes back into main index)
  every :sunday, at: '3AM' do
    set :job, 'weekly_es_reindex'
    rake "elasticsearch:reindex_entry_changes"
    rake "elasticsearch:delete_entry_changes"
  end
end

################################################
# PUBLIC INSPECTION
################################################

if Settings.app.import.public_inspection
  # Import public inspection documents
  # runs every minute from 8AM EDT until 7PM Monday-Friday
  every '* 8-19 * * 1-5' do
    set :job, 'public_inspection_import'
    rake 'content:public_inspection:import_and_deliver'
  end

  every 1.day, at: '12:01 am' do
    set :job, 'destroy_published_pil_agency_letters'
    rake 'content:public_inspection:destroy_published_agency_letters'
  end
end

################################################
# IMAGE PIPELINE
################################################

if Settings.app.images.download_daily_images_from_sftp
  # Download image from SFTP and place in image holding tank bucket on S3
  # Destructive and should only be run in one environment
  every 5.minutes do
    set :job, 'download_daily_images_from_sftp'
    rake 'content:images:download_daily_images_from_sftp'
  end
end

if Settings.app.images.download_historical_images_from_sftp
  # Download image from SFTP and place in image holding tank bucket on S3
  # - uses alternate credentials that have different root folder
  # Destructive and should only be run in one environment
  every 1.day, at: ['6AM', '12PM', '6PM'] do
    set :job, 'download_historical_images_from_sftp'
    rake 'content:images:download_historical_images_from_sftp'
  end
end

if Settings.app.images.download_and_process_from_holding_tank
  every 5.minutes do
    set :job, 'download_and_process_from_holding_tank'
    rake 'content:images:download_and_process_from_holding_tank'
  end
end

################################################
# PLACE DETERMINATIONS FOR HISTORICAL DOCUMENTS
################################################

every [:sunday, :monday], at: '4:00AM' do
  set :job, 'extract_places_for_historical_documents'
  rake 'data:extract:places_for_historical_documents'
end

################################################
# SEMI-ANNUAL UNIFIED AGENDA
################################################

every 1.day, at: '3:00PM' do
  set :job, 'regulatory_plans_schedule'
  rake 'content:regulatory_plans:schedule'
end

################################################
# REGULATIONS.GOV DATA
################################################

if Settings.app.regulations_dot_gov.update_documents
  # At every 55th minute past every hour
  every "*/55 * * * *" do
    set :job, 'regulations_dot_gov_modified_today'
    rake 'content:entries:import:regulations_dot_gov:modified_today'
  end

  every 1.day, at: '12:01AM' do
    set :job, 'regulations_dot_gov_mark_documents_as_closed_for_commenting'
    rake 'content:entries:import:regulations_dot_gov:mark_documents_as_closed_for_commenting'
  end
end

if Settings.app.regulations_dot_gov.update_dockets
  # Download docket data
  every 1.day, at: '12:30PM' do
    set :job, 'docket_import'
    rake 'content:dockets:import'
  end

  # Clear the document cache at a time when the regulations.gov jobs
  # above should have all completed
  every 1.day, at: ['10AM', '2PM'] do
    set :job, 'expire_varnish_for_regulations_dot_gov_changes'
    rake 'varnish:expire:everything'
  end
end


################################################
# GOOGLE ANALYTICS PAGE COUNTS
################################################

if Settings.app.google_analytics.update_document_counts
  # runs every 2 hours at 15 minutes past the hour
  every '15 0,2,4,6,8,10,12,14,16,18,20,22 * * *' do
    set :log, 'google_analytics_api'
    rake 'documents:page_count:update_today'
  end
end
