class RegulationsDotGov::V4::DetailedDocument
  include RegulationsDotGov::V4::CommonDocumentAttributes

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  #TODO: This can probably be moved to the common document attributes since they've added it.
  def federal_register_document_number
    val = raw_attribute_value("frDocNum")
  end

end
