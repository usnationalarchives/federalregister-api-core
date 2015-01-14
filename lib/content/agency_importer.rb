module Content
  class AgencyImporter
    def perform
      # Agency.connection.execute("TRUNCATE agencies")
      # Agency.connection.execute("TRUNCATE agency_assignments")
      # Agency.connection.execute("TRUNCATE agency_names")
      # Agency.connection.execute("TRUNCATE agency_name_assignments")

      agencies_with_parents = {}
      FasterCSV.foreach("data/agencies.csv", :headers => :first_row) do |line|
        agency_data = line.to_hash

        puts "handing #{line['agency_name']}"
        agency = Agency.find_by_name(line["agency_name"]) || Agency.new(:name => line["agency_name"])

        agency.description = line["description"]
        agency.active = line["active"] != "0"
        if line['cfr_citation'].present?
          agency.cfr_citation = ((agency.cfr_citation || '') + "\n" + line['cfr_citation']).strip
        end

        agency.save!

        if line["parent_agency_name"].present?
          agencies_with_parents[agency] = line["parent_agency_name"]
        end
      end

      agencies_with_parents.each_pair do |agency, parent_name|
        parent_agency = Agency.find_by_name!(parent_name)
        if parent_agency != agency
          agency.parent = parent_agency
        else
          agency.parent = nil
        end
        agency.save!
      end
    end
  end
end