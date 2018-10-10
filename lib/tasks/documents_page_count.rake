namespace :documents do
  namespace :page_count do
    task :update_all => :environment do
      DocumentPageViewCount.new.update_all
    end

    task :update_today => :environment do
      DocumentPageViewCount.new.update_counts_for_today
    end
  end
end
