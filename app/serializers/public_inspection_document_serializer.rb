class PublicInspectionDocumentSerializer < ActiveModel::Serializer
  attributes :agency_ids, :publication_date, :special_filing, :title

  def title
    [
      object.subject_1,
      object.subject_2,
      object.subject_3
    ].join(" ")
  end

  def agency_ids
    object.agency_assignments.pluck(:agency_id)
  end
end
