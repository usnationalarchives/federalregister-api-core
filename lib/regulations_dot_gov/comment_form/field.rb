class RegulationsDotGov::CommentForm::Field
  class InvalidInputError < StandardError; end

  RECOGNIZED_FIELD_TYPES = %w(text picklist combo)

  def self.build(client, attributes, agency_acronym)
    raise InvalidInputError, "Invalid field type '#{attributes['uiControl']}'." unless RECOGNIZED_FIELD_TYPES.include?(attributes['uiControl'])

    klass = case attributes['uiControl']
            when 'text'
              TextField
            when 'picklist'
              SelectField
            when 'combo'
              ComboField
            end

    klass.new(client, attributes, agency_acronym)
  end

  attr_reader :client, :attributes, :agency_acronym

  def initialize(client, attributes, agency_acronym)
    @client = client
    @attributes = attributes
    @agency_id = agency_acronym
  end

  def required?
    attributes["required"]
  end

  def publically_viewable?
    attributes["publicViewable"]
  end

  def name
    attributes["attributeName"]
  end

  def label
    attributes["attributeLabel"]
  end

  def hint
    attributes["tooltip"]
  end
end
