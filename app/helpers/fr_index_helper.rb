module FrIndexHelper
  def count_pill(count, options={})
    min = options.delete(:min) || 1
    if count > min
      css_class = ["count_pill", options.delete(:class)].compact.join(' ')

      "&nbsp;" + content_tag(:span, count, options.merge(:class => css_class))
    end
  end

  def needs_attention_pill(count)
    count_pill(count,
      :min => 0,
      :class => "needs_attention tip_under",
      :title => "#{pluralize count, 'item'} #{count > 1 ? 'need' : 'needs'} attention"
    )
  end 
end
