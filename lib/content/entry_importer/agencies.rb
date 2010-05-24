module Content::EntryImporter::Agencies
  extend Content::EntryImporter::Utils
  provides :agency_name_assignments
  
  def agency_name_assignments
    entry.agency_name_assignments = []
    agency_name_assignments = mods_node.xpath('./xmlns:extension/xmlns:agency').map do |agency_node|
      name = agency_node.content()
      agency_name = AgencyName.find_or_create_by_name(name)
      
      AgencyNameAssignment.new(:agency_name => agency_name, :position => agency_node['order'])
    end
  end
end
