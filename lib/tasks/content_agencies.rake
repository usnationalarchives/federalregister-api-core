namespace :content do
  namespace :agencies do
    desc "Import all GPO agencies from CSV"
    task :import => :environment do
      Content::AgencyImporter.new.perform
    end
    
    desc "Match agency names"
    task :match_names => :environment do
      Content::NameMatcher::Agencies.new.perform
    end
    
    namespace :import do
      desc "Update agencies"
      task :update => :environment do
        csv = FCSV($stdin, :headers => :first_row)
        csv.each do |line|
          agency = Agency.find(line['id'])
          agency.update_attributes!(line.to_hash)
        end
      end
    end
  end
end