class RegulationsDotGov::CommentForm::Option
  attr_reader :client, :attributes

  def initialize(client, attributes)
    @client = client
    @attributes = attributes
  end

  def value
    attributes["value"]
  end

  def label
    attributes["label"]
  end

  def default?
    attributes["@default"] == "true"
  end
end
