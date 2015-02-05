namespace :data do
  task :daily => :environment do
    Content::ImportDriver::EntryDriver.new.perform
  end
  
  namespace :daily do 
    # used to avoid thundering herd after clearing sitewide cache
    task :sleep do
      sleep(60)
    end

    task :basic => %w(
      content:entries:import
      content:entries:import:graphics
      content:entries:extract_equation_pages
      data:extract:places
    )
    
    task :really_quick => %w(
      content:entries:import
      content:issues:mark_complete
    )

    task :quick => %w(
      data:daily:basic
      content:issues:mark_complete
    )
    task :catch_up => %w(
      data:daily:basic
      content:entries:html:compile:all
      content:issues:mark_complete
    )
    
    task :full => %w(
      content:section_highlights:clone
      data:daily:basic
      content:entries:html:compile:all
      sphinx:rebuild_delta
      content:issues:mark_complete
      content:public_inspection:import:entry_id
      content:public_inspection:reindex
      content:fr_index:update_status_cache
      varnish:expire:everything
      mailing_lists:daily_import_email:deliver
      data:daily:sleep
      mailing_lists:entries:deliver
      sitemap:refresh
    )
  end
end
