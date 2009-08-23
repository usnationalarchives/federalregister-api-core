namespace :data do
  namespace :update do
    task :agencies => :environment do
      to_summarize = {}
      
      beginning_of_current_week = (Date.today + 3).beginning_of_week
      to_summarize[:entries_1_year_weekly] = (1..52).to_a.reverse.map{|i| beginning_of_current_week - (i*7)}.map{|date| (date.beginning_of_week .. date.end_of_week)}
      
      beginning_of_current_month = (Date.today.beginning_of_month)
      to_summarize[:entries_5_years_monthly] = (1..60).to_a.reverse.map{|i| beginning_of_current_month.months_ago(i)}.map{|date| (date.beginning_of_month .. date.end_of_month) }
      
      to_summarize[:entries_all_years_quarterly] = []
      first_entry_date = Entry.first(:order => "publication_date").publication_date.beginning_of_quarter
      date = (Date.today.beginning_of_quarter).months_ago(3)
      while(date >= first_entry_date) 
        to_summarize[:entries_all_years_quarterly].unshift (date.beginning_of_quarter .. date.end_of_quarter)
        date = date.months_ago(3)
      end
      
      Agency.all.each do |agency|
        agency.entries_count = agency.entries.count
        
        to_summarize.each_pair do |field, date_ranges|
          agency[field] = date_ranges.map{|range| Entry.count(:conditions => {:agency_id => agency.descendant_ids + [agency.id], :publication_date => range}) }.to_json
        end
        
        agency.save(false)
      end
    end
  end
end