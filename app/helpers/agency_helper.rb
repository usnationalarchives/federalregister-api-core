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
      agency_string = "#{@agency.name}"
    else
      agency_string = "The #{@agency.name}"
    end
    
    "#{agency_string} publishes articles in the Federal Register. Explore most recent and most cited articles published by #{agency_string}."
  end
end