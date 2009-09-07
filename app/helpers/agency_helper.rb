module AgencyHelper
  def human_range(range_type)
    case range_type
    when 'entries_1_year_weekly'
      "Previous 12 months by week"
    when 'entries_5_years_monthly'
      "Previous 5 years by month"
    when 'entries_all_years_quarterly'
      "All years by quarter"
    end
  end
end