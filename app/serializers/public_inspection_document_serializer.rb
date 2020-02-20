class PublicInspectionDocumentSerializer < ActiveModel::Serializer
  attributes :agency_ids,
    :docket_id,
    :document_number,
    :id,
    :publication_date,
    :special_filing,
    :title

  def docket_id
    object.docket_numbers.pluck(:number)
  end

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
