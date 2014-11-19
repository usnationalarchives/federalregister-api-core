class RegulationsDotGov::CommentForm
  attr_accessor :client, :attributes, :document_attributes

  AGENCY_NAMES = YAML::load_file(Rails.root.join('data', 'regulations_dot_gov_agencies.yml'))

  def initialize(client, attributes)
    @client = client
    @attributes = attributes
    @document_attributes = attributes['document']
    @field_list = attributes['fieldList']
  end

  def allow_attachments?
    # attachments are now always allowed
    true
  end

  def alternative_ways_to_comment
    document_attributes["alternateWaysToComment"]
  end

  def posting_guidelines
    attributes["postingGuidelines"]
  end

  def document_id
    document_attributes['documentId']
  end

  def comments_open_at
    Time.zone.parse(document_attributes['commentStartDate'])
  end

  def comments_close_at
    Time.zone.parse(document_attributes['commentDueDate'])
  end

  def open_for_comment?
    document_attributes['openForComment']
  end

  def has_field?(name)
    fields.any?{|f| f.name == name.to_s}
  end

  def fields
    @fields ||= @field_list.map do |field_attributes|
      Field.build(client, field_attributes, agency_acronym)
    end
  end

  def agency_name
    attributes['agencyName']
  end

  def agency_acronym
    document_attributes['agencyAcronym']
  end

  def agency_id
    raise 'not implemented in v3 api, use agency_acronym!'
  end

  def text_fields
    fields.select{|x| x.is_a?(RegulationsDotGov::CommentForm::Field::TextField) }
  end

  def agency_participates_on_regulations_dot_gov?
    attributes["participating"]
  end

  def humanize_form_data(form_values)
    field_values = fields.map do |field|
      raw_value = form_values[field.name]
      val = case field
            when RegulationsDotGov::CommentForm::Field::TextField
              raw_value
            when RegulationsDotGov::CommentForm::Field::SelectField
              field.option_values.find{|x| x.value == raw_value}.try(:label)
            when RegulationsDotGov::CommentForm::Field::ComboField
              parent_value = form_values[fields.find{|x| x.name == field.dependent_on}.try(:name)]
              if field.dependent_values.include?(parent_value)
                field.options_for_parent_value(parent_value).find{|x| x.value == raw_value}.try(:label)
              else
                raw_value
              end
            end

      {:label => field.label, :values => Array(val)}
    end

    field_values
  end
end
