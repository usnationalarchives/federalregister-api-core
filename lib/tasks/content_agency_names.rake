namespace :content do
  namespace :agency_names do
    desc "Import agency name mappings"
    task :import => [:import_file_data, 'content:agency_assignments:recalculate']
    task :import_file_data => :environment do
      csv = FCSV($stdin, :headers => :first_row)
      csv.each do |line|
        agency_name_str = line['agency_name']
        agency_name = AgencyName.find_by_name(agency_name_str)
        agency_str = line['agency']
        agency = Agency.find_by_name(agency_str)

        void = agency_str.strip.downcase == 'void'
        puts "Agency Name '#{agency_name_str}' not found!" unless agency_name.present?
        puts "Agency '#{agency_str}' not found!" if agency.nil? && agency_str != '' && ! void

        if agency_name && agency_name.unprocessed?
          if void
            agency_name.void = true
          elsif agency
            agency_name.agency = agency
          end
          agency_name.send(:update_without_callbacks)
        end
      end
    end
  end
end
