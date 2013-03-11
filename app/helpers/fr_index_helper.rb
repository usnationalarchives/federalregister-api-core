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

  def max_date_select(index_object)
    select_tag( 'max_date',
                options_for_select(
                  (1..index_object.last_issue_published.month).map{ |m|
                    date = Date.new(index_object.last_issue_published.year,m,1).end_of_month
                    [date.strftime("%B"), date.to_s(:iso)]
                  },
                  index_object.max_date.end_of_month.to_s(:iso)
                )) 
  end
end
