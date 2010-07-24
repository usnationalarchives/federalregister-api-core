namespace :remote do
  namespace :sphinx do 
    desc "Sync sphinx files and rebuild index"
    task :rebuild do
      `cap production sphinx:rebuild_remote_index`
    end
  end
end