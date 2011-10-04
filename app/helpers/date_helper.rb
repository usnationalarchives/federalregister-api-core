module DateHelper

  def date_in_previous_month?(previous_month, date)
    previous_month.beginning_of_month >= date.beginning_of_month
  end

  def date_in_next_month?(next_month, date)
    next_month.end_of_month <= date.end_of_month
  end

  def pi_date_in_previous_month?(previous_month)
    date_in_previous_month?(previous_month, PublicInspectionDocument.earliest_filing_date)
  end

  def pi_date_in_next_month?(next_month)
    date_in_next_month?(next_month, PublicInspectionDocument.latest_filing_date)
  end
end
