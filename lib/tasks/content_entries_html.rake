namespace :content do
  namespace :entries do
    namespace :html do
      namespace :compile do
        def compile_type(type)
          require 'ftools'
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling #{type} for #{date}..."
            Entry.published_on(date).each do |entry|
              Entry.connection.execute("SELECT NOW()") # keep MySQL connection alive; TODO: FIXME
              path = "#{RAILS_ROOT}/data/entries/#{type}/#{entry.document_file_path}.html"
              File.makedirs(File.dirname(path))

              val = Content.render_erb("entries/_#{type}", {:entry => entry})
              File.open(path, 'w') {|f| f.write(val) }
            end
          end
        end
        
        desc "Compile all HTML for entries"
        task :all => [:abstract, :full_text]
        
        desc "Compile full text HTML for entries"
        task :abstract => :environment do
          compile_type('abstract')
        end
        
        desc "Compile full text HTML for entries"
        task :full_text => :environment do
          compile_type('full_text')
        end
      end
    end
  end
end
