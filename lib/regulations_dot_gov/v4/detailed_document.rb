class RegulationsDotGov::V4::DetailedDocument
  include RegulationsDotGov::V4::CommonDocumentAttributes

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def allow_late_comments
        # NOTE: The document-search endpoint has a singular attribute name but the document-details endpoint has a plural attribute name.
    raw_attribute_value('allowLateComments')
  end

end
