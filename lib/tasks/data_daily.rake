namespace :data do
  task :daily => :environment do
    Content::ImportDriver::EntryDriver.new.perform
  end

  namespace :daily do
    task :basic => %w(
      content:entries:import
      content:gpo_images:process_daily_issue_images
      content:entries:json:compile:daily_toc
      
    )

    task :really_quick => %w(
      content:entries:import
      content:gpo_images:process_daily_issue_images
      content:entries:json:compile:daily_toc
      content:entries:json:compile:fr_index
      sphinx:rebuild_delta

      content:issues:mark_complete
      web:notify_of_updated_issue
    )

    task :quick => %w(
      data:daily:basic
      content:issues:mark_complete
    )

    task :catch_up => %w(
      data:daily:basic
      sphinx:rebuild_delta
      content:issues:mark_complete
      web:notify_of_updated_issue
    )

    task :full => %w(
      content:section_highlights:clone
      data:daily:basic
      content:entries:json:compile:daily_toc
      content:agency_assignments:recalculate
      sphinx:rebuild_delta

      content:issues:mark_complete
      content:public_inspection:import:entry_id
      content:public_inspection:reindex

      web:notify_of_new_issue

      content:fr_index:update_status_cache
      content:entries:json:compile:fr_index
      mailing_lists:daily_import_email:deliver
      sitemap:refresh
    )
  end
end
