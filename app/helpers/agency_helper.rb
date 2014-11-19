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
  
  def description_for_agency(agency)
    if agency.name == 'The White House Office'
      agency_string_1 = "#{@agency.name}"
      agency_string_2 = "#{@agency.name}"
    else
      agency_string_1 = "The #{@agency.name}"
      agency_string_2 = "the #{@agency.name}"
    end
    
    "#{agency_string_1} publishes documents in the Federal Register. Explore most recent and most cited documents published by #{agency_string_2}."
  end
end
