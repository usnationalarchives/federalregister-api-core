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
    
    desc "Copy files, rebuild index, and purge delta items from core index"
    task :rebuild_delta => [:rebuild_delta_index, :purge_from_core_index]

    desc "Sync sphinx files and rebuild index"
    task :rebuild_delta_index => :environment do
      delta_index_names = [Entry, Event, RegulatoryPlan].map{|model| model.delta_index_names}.flatten.join(' ')
      `bundle exec cap #{RAILS_ENV} sphinx:rebuild_delta_index -s delta_index_names='#{delta_index_names}'`
    end

    desc "Purge delta items from core index"
    task :purge_from_core_index => :environment do
      [Entry, Event, RegulatoryPlan].each do |model|
        model.find_each(:select => "id, delta", :conditions => {:delta => true}) do |entry|
          model.core_index_names.each do |index_name|
            delete_in_index(index_name, entry.sphinx_document_id)
          end
        end
      end
    end
  end
end
