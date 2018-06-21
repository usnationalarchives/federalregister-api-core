namespace :resque do
  task :throttle => :environment do
    # at: jobs
    # per: second

    # hourly rate limit of 1000
    # docket importer makes 4 total requests per job
    Resque.rate_limit(:reg_gov,
      at: SETTINGS['regulations_dot_gov']['throttle']['at'],
      per: SETTINGS['regulations_dot_gov']['throttle']['per']
    )
  end
end
