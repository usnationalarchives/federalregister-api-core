module Content::EntryImporter::Agencies
  extend Content::EntryImporter::Utils
  provides :agency_name_assignments, :updated_at

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

  def updated_at
    # NOTE: Entries are reindexed based on whether they have changed.  Formerly, when agency name assignments occurred, entries were not being marked as having changed.  As such, we decided to aggressively mark all imported records as having changed (and hence indicating they should all be reindexed by elasticsearch).  This was previously accomplished by always marking the Sphinx 'delta' column as true, but we removed it as a confusing legacy of Sphinx and are effectively marking all entries as having changed by touching their updated_at timestamp.
    Time.current
  end
end
