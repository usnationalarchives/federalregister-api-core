module Content::EntryImporter::Agencies
  extend Content::EntryImporter::Utils
  provides :agency_id
  
  def agency_id
    if entry.secondary_agency_raw
      find_agency_id_by_name(entry.secondary_agency_raw)
    else
      find_agency_id_by_name(entry.primary_agency_raw)
    end
  end
  
  private
    
    def find_agency_id_by_name(name)
      if name
        Agency.find_by_name(primary_agency_raw).try(:id) || AlternativeAgencyName.find_by_name(primary_agency_raw).try(:agency_id)
      end
    end
end
