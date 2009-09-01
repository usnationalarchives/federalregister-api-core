module AgencyHelper
  def human_range(range_type)
    case range_type
    when 'entries_1_year_weekly'
      "12 months by week"
    when 'entries_5_years_monthly'
      "5 years by month"
    when 'entries_all_years_quarterly'
      "All by quarter"
    end
  end
end