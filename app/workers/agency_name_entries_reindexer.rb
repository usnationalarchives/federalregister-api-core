class AgencyNameEntriesReindexer
  include Sidekiq::Worker

  sidekiq_options :queue => :api_core, :retry => 0

  def perform(agency_name_id)
    agency_name = AgencyName.find(agency_name_id)
    agency_name.entries.pre_joined_for_es_indexing.find_in_batches(batch_size: 500) do |entry_batch|
      Entry.bulk_index(entry_batch, refresh: false)
    end
  end

end
