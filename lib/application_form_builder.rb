class ApplicationFormBuilder < Formtastic::SemanticFormBuilder
  def autocomplete_input(method, options)
    attribute_name = object_name + "[" + method.to_s.singularize + "_ids][]"

    label(method, options.delete(:label), options.slice(:required)) +
      template.text_field_tag("", "", 'data-source-url' => options[:source_data_url]) +
      template.hidden_field_tag(attribute_name, '') +
      template.content_tag(:ul, :class => 'selected autocompleter-selected') {
        object.send(method).map do |obj|
          template.content_tag(:li) do
            obj.name + template.hidden_field_tag(attribute_name, obj.id) +
              template.content_tag(:span, 'X', class: 'remove')
          end
        end.join("\n")
      }
  end

  def calendar_input(method, options)
    # don't want to use #{method}_before_type_cast; want to get the value after it has been formatted
    options[:value] ||= @object.send(method).try(:to_s, :mdy)
    label(method, options.delete(:label), options.slice(:required)) + text_field(method, options)
  end
end

# class ApplicationFormBuilder::Errorless < ApplicationFormBuilder
#   self.inline_errors = :none
# end
