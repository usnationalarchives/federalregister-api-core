class PublicInspectionDocumentSerializer < ApplicationSerializer
  attributes :agency_ids,
    :document_number,
    :filed_at,
    :id,
    :publication_date,
    :special_filing,
    :title,
    :type

  attribute :public_inspection_document_id do |object|
    object.id
  end

  attribute :type do |object|
    if object.granule_class == "SUNSHINE"
      "NOTICE"
    else
      object.granule_class
    end
  end

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

  attribute :full_text do |object|
    path = "#{FileSystemPathManager.data_file_path}/public_inspection/raw/#{object.document_file_path}.txt"
    if File.file?(path)
      File.read(path)
    end
  end
end
