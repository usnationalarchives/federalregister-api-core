class RegulationsDotGov::V4::BasicDocument
  include RegulationsDotGov::V4::CommonDocumentAttributes

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def allow_late_comments
    # NOTE: The document-search endpoint has a singular attribute name but the document-details endpoint has a plural attribute name.
    raw_attribute_value('allowLateComment')
  end

  def last_modified_datetime
    Time.parse(raw_attribute_value('lastModifiedDate'))
  end

  def metadata
    # Called in DocketImporter interface, but this attribute was used for backwards compatibility and is no-longer needed.  Keeping it here for now so the DocketImporter code can run without errors, but we probably want to stop setting the metadata attribute in the DocketImporter long-term.
    nil
  end

end
