set :output, lambda { "2>&1 | sed \"s/^/[$(date)] /\" >> #{path}/log/#{log}.log" }

# load container environment
job_type :rake, [
    'cd :path',
    'source /etc/container_environment.sh',
    'rake :task --silent :output',
  ].join(' && ')


########################
# BULK DATA IMPORTS
########################

# Import today's content
# retries every 5 minutes from 4AM to 5PM EDT every day
every "*/5 4-21 * * *" do
  set :log, 'ofr_bulkdata_import'
  rake 'data:daily'
end

if ENV['RAILS_ENV'] != 'development'

  # Expire pages warning of late content at 9AM/10AM
  every '0 9,10 * * 1-5' do
    set  :log, 'late_page_expiration'
    rake 'varnish:expire:pages_warning_of_late_content'
  end

  # Reindex the entire content (collapsing delta indexes back into main index)
  every :sunday, at: '3AM' do
    set :log, 'weekly_sphinx_reindex'
    rake "sphinx:rotate_all"
  end


  ########################
  # PUBLIC INSPECTION
  ########################

  # Import public inspection documents
  # runs every minute from 7AM EDT until 7PM Monday-Friday
  every '* 7-19 * * 1-5' do
    set :log, 'public_inspection_import'
    rake 'content:public_inspection:import_and_deliver'
  end

  # Purge revoked PI documents at 5:15PM
  # runs at 5:15PM/6:15PM EDT M-F
  every '15 17,18 * * 1-5' do
    set :log, 'public_inspection_import'
    rake 'content:public_inspection:purge_revoked_documents'
  end


  ########################
  # GPO IMAGE IMPORTS
  ########################

  # Download image from FTP and place in private bucket on S3
  # destructive and should only be run in one environment
  if ENV['RAILS_ENV'] == 'production'
    every 15.minutes do
      set :log, 'gpo_eps_importer'
      rake 'content:gpo_images:import'
    end
  end

  # Enqueue background jobs to process any images that are new
  every 5.minutes do
    set :log, 'gpo_eps_converter'
    rake 'content:gpo_images:convert'
  end


  ########################
  # REGULATIONS.GOV DATA
  ########################

  # Find the matching regulations.gov URL for documents added to regs.gov
  # after our daily import
  every 1.day, at: '6AM' do
    set :log, 'reg_gov_url_import_tardy'
    rake 'content:entries:import:regulations_dot_gov:tardy'
  end

  # # Find the matching regulations.gov URL for articles
  # # runs every hour from 7AM EDT until 5PM M-F
  every '30 7-17 * * 1-5' do
    set :log, 'reg_gov_url_import'
    rake 'content:entries:import:regulations_dot_gov:only_missing'
  end

  # Download docket data
  every 1.day, at: '12:30PM' do
    set :log, 'docket_import'
    rake 'content:dockets:import'
  end

  # Confirm URLs and openness of comments that have a valid comment URL
  every 1.day, at: ['5AM', '12PM'] do
    set :log, 'reg_gov_url_import_open_comments'
    rake 'content:entries:import:regulations_dot_gov:open_comments'
  end

  # Clear the document cache at a time when the regulations.gov jobs above
  # should have all completed
  every 1.day, at: ['7AM', '1PM'] do
    rake 'varnish:expire:everything'
  end


  #################################
  # REGULATIONS.GOV COMMENTS
  #################################

  # Refresh the regulations.gov comment form cache
  every 6.hours do
    set :log, 'regulations_dot_gov_comment_cache'
    rake 'regulations_dot_gov:warm_comment_form_cache'
  end

  # Check for newly posted comments and notify users
  every 1.day, at: '6PM' do
    set :log, 'regulations_dot_gov_comments_posted'
    rake 'regulations_dot_gov:notify_comment_publication'
  end

  #################################
  # GOOGLE ANALYTICS PAGE COUNTS
  #################################

  # runs everyday at 15 minutes past the hour
  every '15 * * * *' do
    set :log, 'document_page_counts'
    rake 'documents:page_count:update_today'
  end
end
