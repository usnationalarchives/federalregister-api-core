namespace :content do
  namespace :cfr do
    desc "Imports a CFR bulkdata file; specify YEAR; optionally specify TITLE and VOLUME"
    task :import => :environment do
      Content::CfrPartsImporter.import(:year => ENV['YEAR'], :title => ENV['TITLE'], :volume => ENV['VOLUME'])
    end
  end
end