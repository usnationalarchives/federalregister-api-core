namespace :documents do
  namespace :page_count do
    task :update_all => :environment do
      PageViewCount.new(PageViewType::DOCUMENT).update_all
      PageViewCount.new(PageViewType::PUBLIC_INSPECTION_DOCUMENT).update_all
    end

    task :update_today => :environment do
      PageViewCount.new(PageViewType::DOCUMENT).update_counts_for_today
      PageViewCount.new(PageViewType::PUBLIC_INSPECTION_DOCUMENT).update_counts_for_today
    end

    task :repopulate_historical_set_from_database! => :environment do
      PageViewCount.new(PageViewType::DOCUMENT).repopulate_historical_set_from_database!
      PageViewCount.new(PageViewType::PUBLIC_INSPECTION_DOCUMENT).repopulate_historical_set_from_database!
    end
  end
end
