class PublicInspectionDocumentSerializer < ApplicationSerializer
  attributes :agency_ids,
    :document_number,
    :id,
    :publication_date,
    :special_filing,
    :title

  attribute :docket_id do |object|
    object.docket_numbers.pluck(:number)
  end

  attribute :title do |object|
    [
      object.subject_1,
      object.subject_2,
      object.subject_3
    ].join(" ")
  end

  attribute :agency_ids do |object|
    object.agency_assignments.pluck(:agency_id)
  end
end
