namespace :sphinx do
  desc "Rebuild delta indexes and purge delta items from core index"
  task :rebuild_delta => :environment do
    SphinxIndexer.rebuild_delta_and_purge_core(Entry)
  end

  task :rotate_all => :environment do
    SphinxIndexer.rotate_all
  end

  task :restart => :environment do
    SphinxIndexer.restart
  end
end
