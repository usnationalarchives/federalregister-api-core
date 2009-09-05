class Citation < ActiveRecord::Base
  CITATION_TYPES = {
    'USC' => /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/,
    'CFR' => /(\d+)\s+CFR\s+(\d+)(?:\.(\d+))?/,
    'FR'  => /(\d+)\s+FR\s+(\d+)/,
    'PL'  => /Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+)/
  }
  
  belongs_to :source_entry, :class_name => "Entry"
  belongs_to :cited_entry,  :class_name => "Entry"
    
  def self.extract!(entry)
    text = entry.full_text_raw
    CITATION_TYPES.each_pair do |citation_type, regexp|
      text.scan(regexp) do |part_1, part_2, part_3|
        attributes = {:source_entry_id => entry.id, :citation_type => citation_type, :part_1 => part_1, :part_2 => part_2, :part_3 => part_3}
        
        citation = Citation.first(:conditions => attributes)
        
        if citation.nil?
          citation = Citation.new(attributes)
          
          if citation_type == 'FR' && part_1.to_i >= 59
            entries = Entry.find_all_by_citation(part_1, part_2)
          
            if entries.size == 1
              citation.cited_entry_id = entries.first.id
            end
          end
          
          citation.save
        end
      end
    end
  end
end