namespace :sphinx do
  desc "Rebuild index and purge delta items from core index"
  task :rebuild_delta => [:rebuild_delta_index]

  desc "Rebuild delta indexes"
  task :rebuild_delta_index => :environment do
    delta_index_names = [Entry].map{|model| model.delta_index_names}.flatten.join(' ')
    SphinxIndexer.perform(delta_index_names)
  end
end
