module Content
  class AgencyImporter
    def perform
      Agency.connection.execute("TRUNCATE agencies")
      Agency.connection.execute("TRUNCATE agency_assignments")
      # Agency.connection.execute("TRUNCATE agency_names")
      # Agency.connection.execute("TRUNCATE agency_name_assignments")
      
      agencies_with_parents = {}
      FasterCSV.foreach("data/gpo_agencies.csv", :headers => :first_row) do |line|
        agency_data = line.to_hash
        
        agency = Agency.create(:name => line["name"])
        
        if line["parent_name"].present?
          agencies_with_parents[agency] = line["parent_name"]
        end
      end
      
      agencies_with_parents.each_pair do |agency, parent_name|
        agency.parent = Agency.find_by_name(parent_name)
        agency.save
      end
    end
  end
end