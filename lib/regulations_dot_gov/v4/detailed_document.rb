class RegulationsDotGov::V4::DetailedDocument
  extend Memoist
  include RegulationsDotGov::V4::CommonDocumentAttributes

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def comment_count
    RegulationsDotGov::V4::Client.new.find_comments_by_comment_on_id(comment_on_id).count
  end
  memoize :comment_count

  def federal_register_document_number
    val = raw_attribute_value("frDocNum")
  end

  private

  def comment_on_id
    raw_attribute_value('objectId')
  end

end
