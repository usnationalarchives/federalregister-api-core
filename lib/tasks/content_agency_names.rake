namespace :content do
  namespace :agency_names do
    desc "Import agency name mappings"
    task :import => :environment do
      csv = FCSV($stdin, :headers => :first_row)
      csv.each do |line|
        agency_name_str = line['agency_name']
        agency_name = AgencyName.find_by_name(agency_name_str)
        agency_str = line['agency']
        agency = Agency.find_by_name(agency_str)
        
        puts "AN '#{agency_name_str}' not found!" unless agency_name.present?
        puts "A '#{agency_str}' not found!" if agency.nil? && agency_str != '' && agency_str != 'Void'
        
        if agency_name && agency_name.unprocessed?
          if agency_str == 'Void'
            agency_name.void = true
          elsif agency
            agency_name.agency = agency
          end
          agency_name.save!
        end
      end
    end
  end
end