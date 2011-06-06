namespace :content do
  namespace :cfr do
    desc "Imports a CFR bulkdata file; specify YEAR; optionally specify TITLE and VOLUME"
    task :import => :environment do
      Content::CfrPartsImporter.import(:year => ENV['YEAR'], :title => ENV['TITLE'], :volume => ENV['VOLUME'])
    end

    desc "Downloads the CFR bulkdata by year Usage: content:cfr:download YEAR=2011"
    task :download => :environment do
      Content::CfrBulkdataDownloader.download(:year => ENV['YEAR'], :force_download => ENV['FORCE'])
    end
  end
end
