namespace :data do
  task :daily => %w(
    data:daily:quick
    content:entries:import:regulations_dot_gov:tardy
    tmp:cache:clear
    content:entries:html:compile:all
    thinking_sphinx:index
    sitemap:refresh
  )
  
  namespace :daily do 
    task :quick => %w(
    content:section_highlights:clone
    content:entries:import
    
    content:entries:import:graphics
    data:extract:places
    )
  end
end