class RegulationsDotGov::V4::DetailedDocument
  include RegulationsDotGov::V4::CommonDocumentAttributes

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def allow_late_comments
    raw_attribute_value('allowLateComments')
  end

end
