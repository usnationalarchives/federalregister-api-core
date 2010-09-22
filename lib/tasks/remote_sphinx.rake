namespace :remote do
  namespace :sphinx do 
    desc "Sync sphinx files and rebuild index"
    task :rebuild do
      `cap #{RAILS_ENV} sphinx:rebuild_remote_index`
    end
  end
end