# This houses logic that probably belongs at hte view level, but
#  for now needs to be accessible at the model level.
# Shared by Entry and FrIndexPresenter::Entry
module EntryViewLogic
  def publication_month
    publication_date.strftime('%B')
  end

  def human_length
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
  end

  def page_range
    if human_length > 1
      "#{start_page}-#{end_page}"
    else
      start_page
    end
  end
end