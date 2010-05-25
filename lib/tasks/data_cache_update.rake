namespace :data do
  namespace :cache do
    namespace :update do
      task :all => [:topics, :agencies]
      
      task :topics => :environment do
        Topic.find_each do |topic|
          puts "updating topic #{topic.id}.."
          
          topic.related_topics_cache = Topic.find_by_sql(["SELECT topics.*, COUNT(*) AS entries_count
          FROM topics AS our_topics
          LEFT JOIN topic_assignments AS our_topic_assignments
            ON our_topic_assignments.topic_id = our_topics.id
          LEFT JOIN topic_assignments
            ON topic_assignments.entry_id = our_topic_assignments.entry_id
          LEFT JOIN topics
            ON topics.id = topic_assignments.topic_id
          WHERE our_topics.group_name = ?
            AND topics.group_name != ?
            AND topics.group_name != ''
          GROUP BY topics.group_name
          ORDER BY entries_count DESC, LENGTH(topics.name)
          LIMIT 100", topic.group_name, topic.group_name]).map{|t| {"name" => t.name, "group_name" => t.group_name, "entries_count" => t.entries_count} }
        
          topic.related_agencies_cache = Agency.all(:select => 'agencies.*, count(*) AS entries_count',
            :joins => {:entries => :topics},
            :conditions => {:entries => {:topics => {:group_name => topic.group_name}}},
            :group => "agencies.id",
            :order => 'entries_count DESC'
          ).map{|agency| {"name" => agency.name, "entries_count" => agency.entries_count} }
          
          topic.save!
        end
      end
    
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
      
        Agency.find_each do |agency|
          puts "updating agency #{agency.id}..."
          agency.entries_count = agency.entries.count
        
          to_summarize.each_pair do |field, date_ranges|
            agency[field] = date_ranges.map{|range| Entry.count(:conditions => {:agency_assignments => {:agency_id => agency.id}, :entries => {:publication_date => range}}, :joins => :agency_assignments) }
          end
          agency.save!
        end
      end
    end
  end
end