namespace :data do
  task :daily => %w(
    data:daily:quick
    
    data:cache:update:all
    data:cache:expire
    tmp:cache:clear
    thinking_sphinx:index
    sitemap:refresh
  )
  
  namespace :daily do 
    task :quick => %w(
    content:entries:import
    data:import:bulkdata
    data:download:full_text
    
    content:section_highlights:clone
    content:entries:import:graphics
    
    data:extract:places
    data:extract:regulationsdotgov_id
    )
  end
end