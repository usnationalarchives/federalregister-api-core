namespace :content do
  namespace :entries do
    namespace :html do
      namespace :compile do
        def compile_type(type)
          require 'ftools'
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling #{type} for #{date}..."
            Content::EntryCompiler.perform(type, date)
          end
        end

        desc "Compile all HTML for entries"
        task :all => [:abstract, :full_text]

        desc "Compile abstract HTML for entries"
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
