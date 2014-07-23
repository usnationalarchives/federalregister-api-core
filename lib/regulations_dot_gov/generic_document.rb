class RegulationsDotGov::GenericDocument
  attr_reader :raw_attributes

  def initialize(client, raw_attributes)
    @client = client
    @raw_attributes = raw_attributes
  end
end
