namespace :data do
  task :daily => %w(
    data:daily:catch_up
    content:entries:import:regulations_dot_gov:tardy
    tmp:cache:clear
    sitemap:refresh
  )
  
  namespace :daily do 
    task :quick => %w(
      content:section_highlights:clone
      content:entries:import
      content:entries:import:graphics
      data:extract:places
    )
    
    task :catch_up => %w(
      data:daily:quick
      content:entries:html:compile:all
    )
  end
end