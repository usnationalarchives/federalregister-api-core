module ReferencedDateHelper
  def show_date_type(date_type, entry_count)
    case date_type
    when 'EffectiveDate'
      "Entries Effective on This Day (#{entry_count})"
    when 'CommentDate'
      "Comments Closed on This Day (#{entry_count})"
    end
  end
end