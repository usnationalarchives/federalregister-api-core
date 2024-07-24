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

    desc "Update most recent pai_year attribute based on what is available at GovInfo"
    task :update_pai_years => :environment do
      PrivacyActUpdater.update_agency_pai_years!
    end

    namespace :import do
      desc "Update agencies"
      task :update => :environment do
        csv = FCSV($stdin, :headers => :first_row)
        csv.each do |line|
          agency = Agency.find(line['id'])
          agency.update!(line.to_hash)
        end
      end
    end
  end
end
