class AgencyNameChangeReindexer
  include Sidekiq::Worker

  sidekiq_options :queue => :api_core, :retry => 0

  def perform(agency_name_id, prior_agency_id)
    agency_name    = AgencyName.find(agency_name_id)
    current_agency = agency_name.agency
    prior_agency   = Agency.find_by_id(prior_agency_id)

    if current_agency.blank? && prior_agency_id.blank?
      # No need to reindex anything
      entry_ids = []
    elsif SETTINGS['feature_flags']['reindex_all_agency_name_entries']
      # This setting can be toggled as a means for aggressively reindexing all associated entries
      entry_ids = agency_name.entry_ids
    elsif current_agency.blank? && prior_agency
      entry_ids_associated_with_prior_agency_via_other_agency_name_ids = prior_agency.agency_name_assignments.where(
        assignable_type: 'Entry',
        assignable_id:   agency_name.entry_ids,
        agency_name_id:  prior_agency.agency_name_ids
      ).pluck(:assignable_id)

      entry_ids = (agency_name.entry_ids - entry_ids_associated_with_prior_agency_via_other_agency_name_ids)
    elsif current_agency && prior_agency.blank?
      other_agency_name_ids = current_agency.agency_name_ids - agency_name.id
      entry_ids_already_associated_with_current_agency_via_other_agency_name_ids = current_agency.agency_name_assignments.where(
        assignable_type: 'Entry',
        assignable_id:   agency_name.entry_ids,
        agency_name_id:  other_agency_name_ids
      ).pluck(:assignable_id)

      entry_ids = (agency_name.entry_ids - entry_ids_already_associated_with_current_agency_via_other_agency_name_ids)
    elsif current_agency && prior_agency
      other_agency_name_ids = current_agency.agency_name_ids - agency_name.id
      entry_ids_already_associated_with_current_agency_via_other_agency_name_ids = current_agency.agency_name_assignments.where(
        assignable_type: 'Entry',
        assignable_id:   agency_name.entry_ids,
        agency_name_id:  other_agency_name_ids
      ).pluck(:assignable_id)

      entry_ids_associated_with_the_prior_agency_via_other_agency_name_ids = prior_agency.agency_name_assignments.where(
        assignable_type: 'Entry',
        assignable_id:   agency_name.entry_ids,
        agency_name_id:  prior_agency.agency_name_ids
      ).pluck(:assignable_id)

      entry_ids = (agency_name.entry_ids - entry_ids_already_associated_with_current_agency_via_other_agency_name_ids - entry_ids_associated_with_the_prior_agency_via_other_agency_name_ids)
    else
      raise NotImplementedError
    end
    
    if entry_ids.present?
      attribute = EntrySerializer.attributes_to_serialize.find{|k,v| k == :agency_ids}.last
      Entry.where(id: entry_ids).includes(:agencies).find_in_batches(batch_size: 10000) do |entry_batch|
        Entry.bulk_update(entry_batch, refresh: false, attribute: attribute)
      end
    end
  end

end
