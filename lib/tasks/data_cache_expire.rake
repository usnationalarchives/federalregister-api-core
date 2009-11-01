namespace :data do
  namespace :cache do
    desc "Manually delete all full-page cache entries"
    task :expire do
      RAILS_ROOT = "#{File.dirname(__FILE__)}/../.." unless defined?(RAILS_ROOT)
      
      locations = [
        'agencies.html',
        'agencies',
        'entries',
        'events',
        'index.html',
        'places'
      ]
      public_dir = RAILS_ROOT + '/public'
      locations.each do |location|
        path = "#{public_dir}/#{location}"
        puts "deleting #{path}"
        `sudo rm -rf #{path}`
      end
    end
  end
end