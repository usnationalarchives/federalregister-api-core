namespace :remote do
  namespace :sphinx do 
    desc "Sync sphinx files and rebuild index"
    task :rebuild do
      `cap #{RAILS_ENV} sphinx:rebuild_remote_index`
    end
    
    desc "Sync sphinx files and rebuild index"
    task :rebuild_delta => :environment do
      delta_index_names = [Entry, Event, RegulatoryPlan].map{|model| model.delta_index_names}.flatten.join(' ')
      `cap #{RAILS_ENV} sphinx:rebuild_delta_index -s delta_index_names='#{delta_index_names}'`
    end
  end
end