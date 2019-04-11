class RegulationsDotGov::CommentForm::Field::ComboField < RegulationsDotGov::CommentForm::Field
  class UnrecogonizedDependencyError < StandardError; end

  MAPPING = {
    'country' => ['United States', 'Canada'],
    'gov_agency_type' => ['Federal']
  }

  def dependent_on
    attributes['dependsOn']
  end

  def lookup_name
    attributes['lookupName']
  end

  def dependent_values
    MAPPING[dependent_on] or raise UnrecogonizedDependencyError, "Combo field #{name} has unrecognized dependency for #{dependent_on}; needs to be configured."
  end

  def dependencies
    dependencies = {}
    dependent_values.each do |val|
      dependencies[val] = options_for_parent_value(val).map do |option|
        [option.value, option.label]
      end
    end

    dependencies
  end

  def options_for_parent_value(val)
    client.get_option_elements(name, 'dependentOnValue' => val)
  end
end

#{
    #"attribute": "US_STATE",
    #"attributeLabel": "State or Province",
    #"attributeName": "us_state",
    #"category": "PUBLIC SUBMISSIONS",
    #"controlLines": "1",
    #"dependsOn": "country",
    #"groupId": "si_address",
    #"lookupName": "us_state_v",
    #"maxLength": 50,
    #"sequence": 5240,
    #"tooltip": "Submitter's state",
    #"uiControl": "combo"
#}
