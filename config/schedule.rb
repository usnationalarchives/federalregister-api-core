set :output, lambda { "2>&1 | sed \"s/^/[$(date)] /\" >> #{path}/log/#{log}.log" }

# load container environment
job_type :rake, [
    'cd :path',
    'source /etc/container_environment.sh',
    'bundle exec rake :task --silent :output',
  ].join(' && ')


# Import today's content
# retries every 5 minutes from 4AM to 5PM EDT every day
every "*/5 4-21 * * *" do
  set :log, 'ofr_bulkdata_import'
  rake 'data:daily'
end

# # Find the matching regulations.gov URL for articles
# # runs every hour from 7AM EDT until 5PM M-F
every '30 7-17 * * 1-5' do
  set :log, 'reg_gov_url_import'
  rake 'content:entries:import:regulations_dot_gov:only_missing'
end

# Find the matching regulations.gov URL for documents added to regs.gov
# after our daily import
every 1.day, at: ['6AM'] do
  set :log, 'reg_gov_url_import_tardy'
  rake 'content:entries:import:regulations_dot_gov:tardy'
end

# Download docket data
every 1.day, at: ['12:30PM'] do
  set :log, 'docket_import'
  rake 'content:dockets:import'
end

# Confirm URLs and openness of comments that have a valid comment URL
every 1.day, at: ['5AM,12PM'] do
  set :log, 'reg_gov_url_import_open_comments'
  rake 'content:entries:import:regulations_dot_gov:open_comments'
end

# Expire pages warning of late content at 9AM/10AM
every '0 9,10 * * 1-5' do
  set  :log, 'late_page_expiration'
  rake 'varnish:expire:pages_warning_of_late_content'
end

# Reindex the entire content (collapsing delta indexes back into main index)
every 1.day, at: ['3AM'] do
  set :log, 'weekly_sphinx_reindex'
  command '/usr/local/bin/indexer --config /home/app/config/sphinx.conf --rotate --all --sighup-each'
end

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
