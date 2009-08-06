
def soundex(string)
  copy = string.upcase.tr '^A-Z', ''
  return nil if copy.empty?
  first_letter = copy[0, 1]
  copy.tr_s! 'AEHIOUWYBFPVCGJKQSXZDTLMNR', '00000000111122222222334556'
  copy.sub!(/^(.)\1*/, '').gsub!(/0/, '')
  "#{first_letter}#{copy.ljust(3,"0")}"
end

def cleanup_name(n)
  return '' if n.blank?
  
  name = "#{n}"
  # name.gsub!(/(?:U\b\.?S\b\.?|united states)/i, '') # remove U.S.
  
  name.downcase!
  
  # remove parentheticals
  name.sub!(/\(.*\)/, '')
  name.sub!(/\[.*\]/, '')
  name.sub!(/\\\\.*/, '')
  
  # remove semicolons on
  name.sub!(/;.*/,'')
  
  # remove parens on
  name.sub!(/\(.*/,'')
  
  # remove garbage at the end
  name.sub!(/(?: and)?\W*$/, '')
  
  # remove ugly characters
  name.gsub!(/[^a-z ]/,' ')
  
  # remove stop words
  name.gsub!(/\b(?:and|by|the|a|an|of|in|on|to|for|s|etc|department|agency|bureau|administration|comission|authority)\b/, ' ')
  
  # cleanup whitespace
  name.gsub!(/ {2,}/, ' ')
  name.gsub!(/^ /, '')
  name.gsub!(/ $/, '')
  
  
  name
end

def find_agency(name, agencies)
  include Amatch
  return nil if name.blank?
  
  cleaned_name = cleanup_name(name)
  to_match = soundex(cleaned_name)
  
  selected_agency = nil
  min_closeness = 3
  
  agencies.each do |agency, matcher|
    matcher = Sellers.new(soundex(cleanup_name(agency.name)) )
    closeness = matcher.match(to_match)
    
    if closeness < min_closeness
      selected_agency = agency
      min_closeness = closeness
    end
  end

  selected_agency
end

namespace :data do
  namespace :extract do
    desc "Assign agencies to entries based on raw agency names"
    task :agencies => :environment do 
      
      all_agencies = Agency.all
      
      Entry.find_in_batches do |entry_group|
        entry_group.each do |entry|
          if entry.primary_agency_raw
            parent_agency = find_agency(entry.primary_agency_raw, all_agencies)
          end
          
          if parent_agency
            child_agency = find_agency(entry.secondary_agency_raw, parent_agency.children)
            
            entry.agency = child_agency || parent_agency
          else
            entry.agency = find_agency(entry.secondary_agency_raw, all_agencies)
          end
          
          if entry.agency_id.nil?
            puts "NO MATCH FOR '#{cleanup_name entry.primary_agency_raw}' OR '#{cleanup_name entry.secondary_agency_raw}'"
            entry.agency = nil
          end
          
          entry.save
        end
      end
    end
  end
end