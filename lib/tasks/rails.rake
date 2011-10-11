namespace :db do
  task :migrate do
    # after the regular migrate task, annotate models if in development mode
    if Rails.env == 'development'
      Rake::Task["annotate_models"].invoke
    end
  end
end
