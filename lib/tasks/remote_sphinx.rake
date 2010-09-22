namespace :remote do
  namespace :sphinx do 
    desc "Sync sphinx files and rebuild index"
    task :rebuild do
      `cap #{RAILS_ENV} sphinx:rebuild_remote_index`
    end
    
    desc "Sync sphinx files and rebuild index"
    task :rebuild_delta do
      `cap #{RAILS_ENV} sphinx:rebuild_delta_index`
    end
  end
end