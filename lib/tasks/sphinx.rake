namespace :sphinx do
  desc "Rebuild delta indexes and purge delta items from core index"
  task :rebuild_delta => :environment do
    SphinxIndexer.rebuild_delta_and_purge_core(Entry)
  end
end
