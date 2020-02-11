class PublicInspectionDocumentSerializer < ActiveModel::Serializer
  attributes :agency_ids, :publication_date

  def agency_ids
    object.agency_assignments.pluck(:agency_id)
  end
end
