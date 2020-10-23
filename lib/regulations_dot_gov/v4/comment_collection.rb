class RegulationsDotGov::V4::CommentCollection

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def count
    raw_attributes.fetch('totalElements')
  end

  private

  attr_reader :raw_attributes

end
