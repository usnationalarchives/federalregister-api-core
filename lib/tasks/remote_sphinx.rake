namespace :remote do
  namespace :sphinx do 
    task :rebuild do
      `cap production sphinx:rebuild_remote_index`
    end
  end
end