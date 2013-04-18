namespace :sphinx do
  desc "Rebuild index and purge delta items from core index"
  task :rebuild_delta => [:rebuild_delta_index, :purge_from_core_index]

  desc "Rebuild delta indexes"
  task :rebuild_delta_index => :environment do
    delta_index_names = [Entry, Event, RegulatoryPlan].map{|model| model.delta_index_names}.flatten.join(' ')
    SphinxIndexer.perform(delta_index_names)
  end

  desc "Purge delta items from core index"
  task :purge_from_core_index => :environment do
    [Entry, Event, RegulatoryPlan].each do |model|
      model.find_each(:select => "id, delta", :conditions => {:delta => true}) do |record|
        model.core_index_names.each do |index_name|
          model.delete_in_index(index_name, record.sphinx_document_id)
        end
      end
    end
  end
end
