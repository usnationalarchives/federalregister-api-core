namespace :data do
  namespace :import do
    desc "Import agencies CSV file into the database"
    task :agencies => :environment do
      require 'fastercsv'
      
      Agency.connection.execute("TRUNCATE agencies")
      
      Agency.transaction do
        FasterCSV.foreach("data/agencies.csv", :headers => :first_row) do |line|
          agency_attributes = line.to_hash
          parent_agency_name = agency_attributes.delete("parent")
          
          if parent_agency_name
            agency_attributes["parent_id"] = Agency.find_by_name!(parent_agency_name)
          end
          
          Agency.create(agency_attributes)
        end
      end
    end
  end
end