class RegulationsDotGov::CommentForm::Field::SelectField < RegulationsDotGov::CommentForm::Field
  def option_values
    @options ||= client.get_option_elements(name, option_parameters)
  end

  def default
    options.first(&:default?)
  end

  def option_parameters
    parameters = {}
    if name == 'comment_category'
      parameters['dependentOnValue'] = agency_id
    end
    parameters
  end
end
