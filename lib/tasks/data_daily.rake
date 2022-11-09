namespace :data do
  task :daily => :environment do
    Content::ImportDriver::EntryDriver.new.perform
  end

  namespace :daily do
    task :development => %w(
      content:entries:import
      content:entries:json:compile:daily_toc
      elasticsearch:reindex_entry_changes
      content:issues:mark_complete
      web:notify_of_updated_issue
      content:fr_index:update_status_cache
      content:entries:json:compile:fr_index
    )

    task :basic => %w(
      content:entries:import
      data:extract:places
      content:gpo_images:process_daily_issue_images
      content:entries:json:compile:daily_toc
      content:entries:enqueue_regs_dot_gov_import
    )

    task :really_quick => %w(
      content:entries:import
      content:gpo_images:process_daily_issue_images
      content:entries:json:compile:daily_toc

      elasticsearch:reindex_entry_changes

      content:issues:mark_complete
      web:notify_of_updated_issue
    )

    task :quick => %w(
      data:daily:basic
      content:issues:mark_complete
    )

    task :catch_up => %w(
      data:daily:basic
      elasticsearch:reindex_entry_changes
      content:issues:mark_complete
      web:notify_of_updated_issue
    )

    task :full => %w(
      content:section_highlights:clone
      data:daily:basic
      content:public_inspection:import:entry_id
      elasticsearch:reindex_entry_changes

      content:issues:mark_complete
      
      content:public_inspection:reindex

      web:notify_of_new_issue

      content:fr_index:update_status_cache
      content:entries:json:compile:fr_index
      mailing_lists:daily_import_email:deliver
    )

    task :reimport => %w(
      content:entries:reimport
      content:gpo_images:process_daily_issue_images
      content:entries:json:compile:daily_toc

      content:public_inspection:import:entry_id
      elasticsearch:reindex_entry_changes

      content:public_inspection:reindex

      web:notify_of_updated_issue

      content:fr_index:update_status_cache
      content:entries:json:compile:fr_index

      varnish:expire:everything
    )
  end
end
