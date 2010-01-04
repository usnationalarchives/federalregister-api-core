namespace :data do
  task :daily => %w(
    data:download:entries
    data:import:entries
    data:import:bulkdata
    data:download:full_text
    data:extract:agencies
    data:extract:places
    data:extract:regulationsdotgov_id
    data:update:agencies
    data:cache:expire
    thinking_sphinx:index
    sitemap:refresh
  )
end