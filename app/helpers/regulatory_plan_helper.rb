module RegulatoryPlanHelper
  def fuzzy_date_formatter(date)
    case date
    when nil
      ni
    when /\d{4}-\d{2}-00/
      Date.parse(date.next).to_s(:month_year)
    when /\d{4}-\d{2}-\d{2}/
      Date.parse(date).to_s(:long_ordinal)
    else
      date
    end
  end
  
  def issue_season(plan)
    (year, season) = plan.issue.match(/(\d{4})(\d{2})/)[1,2]
    
    "#{season == '04' ? 'Spring' : 'Fall'} #{year}"
  end
end