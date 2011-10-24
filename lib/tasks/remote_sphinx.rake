namespace :remote do
  namespace :sphinx do 
    desc "Sync sphinx files and rebuild index"
    task :rebuild do
      `bundle exec cap #{RAILS_ENV} sphinx:rebuild_remote_index`
    end
    
    desc "Re-index (collapses delta indexes back into main index)"
    task :reindex do
      `bundle exec cap #{RAILS_ENV} sphinx:run_sphinx_indexer`
    end
    
    desc "Sync sphinx files and rebuild index"
    task :rebuild_delta => :environment do
      delta_index_names = [Entry, Event, RegulatoryPlan].map{|model| model.delta_index_names}.flatten.join(' ')
      `bundle exec cap #{RAILS_ENV} sphinx:rebuild_delta_index -s delta_index_names='#{delta_index_names}'`
    end
  end
end
