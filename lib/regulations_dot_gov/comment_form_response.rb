class RegulationsDotGov::CommentFormResponse
  attr_reader :raw_attributes

  def initialize(client, raw_attributes)
    @client = client
    @raw_attributes = raw_attributes
  end

  def developer_message
    @raw_attributes['developerMessage']
  end

  def message
    @raw_attributes['message']
  end

  def tracking_number
    @raw_attributes['trackingNumber']
  end

  def status
    @raw_attributes['status']
  end

  def uploaded_files
    @raw_attributes['uploadedFiles'] || []
  end
end
