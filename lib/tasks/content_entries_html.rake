namespace :content do
  namespace :entries do
    namespace :html do
      desc "Compile HTML for article full text"
      task :compile => :environment do
        require 'ftools'
        
        dates = Content.parse_dates(ENV['DATE'])
        
        dates.each do |date|
          puts "compiling HTML for #{date}..."
          Entry.published_on(date).each do |entry|
            Entry.connection.execute("SELECT NOW()") # keep MySQL connection alive; TODO: FIXME
            path = "#{RAILS_ROOT}/public/articles/#{entry.document_file_path}.html"
            File.makedirs(File.dirname(path))
            
            val = Content.render_erb('entries/_full_text', {:entry => entry})
            File.open(path, 'w') {|f| f.write(val) }
          end
        end
      end
    end
  end
end
