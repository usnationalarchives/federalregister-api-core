class ApplicationFormBuilder < Formtastic::SemanticFormBuilder
  def autocomplete_input(method, options)
    attribute_name = object_name + "[" + method.to_s.singularize + "_ids][]"
    
    label(method, options.delete(:label), options.slice(:required)) +
      template.text_field_tag("", "", 'data-source-url' => options[:source_data_url]) + 
      template.hidden_field_tag(attribute_name, '') + 
      template.content_tag(:ul, :class => 'selected') {
        object.send(method).map do |obj|
          template.content_tag(:li, obj.name + template.hidden_field_tag(attribute_name, obj.id))
        end
      }
  end
end