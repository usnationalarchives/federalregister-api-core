module FrIndexHelper
  def count_pill(count)
    pill = ['&nbsp;']
    pill << content_tag(:span, count, :class => "count_pill") if count > 1
    pill.join(' ')
  end
end
