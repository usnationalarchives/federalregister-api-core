module FrIndexHelper
  def count_pill(count, options={})
   if count > 1
      css_class = ["count_pill", options.delete(:class)].compact.join(' ')

      "&nbsp;" + content_tag(:span, count, options.merge(:class => css_class))
    end
  end
end
