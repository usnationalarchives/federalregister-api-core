namespace :content do
  namespace :agency_names do
    desc "Import agency name mappings"
    task :import => :environment do
      csv = FCSV($stdin, :headers => :first_row)
      csv.each do |line|
        agency_name = AgencyName.find_by_name!(line['agency_name'])
        agency = line['agency']
        
        puts "Processing '#{agency_name.name}' (#{agency})"
        if agency_name.unprocessed?
          if agency == 'Void'
            agency_name.void = true
          else
            agency_name.agency = Agency.find_by_name!(agency)
          end
          agency_name.save!
        else
          puts "skipping...already processed."
        end
      end
    end
  end
end