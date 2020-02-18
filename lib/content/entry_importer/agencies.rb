module Content::EntryImporter::Agencies
  extend Content::EntryImporter::Utils
  provides :agency_name_assignments

  MAX_RETRIES = 1
  RETRY_DELAY = 1
  def agency_name_assignments
    retries = 0
    begin
      entry.agency_name_assignments = []
    rescue ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout => e
      if retries < MAX_RETRIES
        sleep RETRY_DELAY
        retries += 1
        retry
      end
    end

    agency_name_assignments = mods_node.xpath('./xmlns:extension/xmlns:agency').map do |agency_node|
      name = agency_node.content()
      agency_name = AgencyName.find_or_create_by(name: name)

      AgencyNameAssignment.new(:agency_name => agency_name, :position => agency_node['order'])
    end
  end
end
