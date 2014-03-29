class RegulationsDotGov::GenericDocument
  attr_reader :raw_attributes

  def initialize(client, raw_attributes)
    @client = client
    @raw_attributes = raw_attributes
    #@metadata = {}
    #if @raw_attributes["metadata"] && @raw_attributes["metadata"]["entry"]
      #metadata_hashes = @raw_attributes["metadata"]["entry"]
      #if metadata_hashes.is_a?(Hash)
        #metadata_hashes = [metadata_hashes]
      #end
      #metadata_hashes.each do |hsh|
        #@metadata[hsh["@name"]] = hsh["$"]
      #end
    #end
  end
end
