=begin Schema Information

 Table name: citations

  id              :integer(4)      not null, primary key
  source_entry_id :integer(4)
  cited_entry_id  :integer(4)
  citation_type   :string(255)
  part_1          :string(255)
  part_2          :string(255)
  part_3          :string(255)

=end Schema Information

class Citation < ActiveRecord::Base
  CITATION_TYPES = {
    'USC' => /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/,
    'CFR' => /(\d+)\s+CFR\s+(\d+)(?:\.(\d+))?/,
    'FR'  => /(\d+)\s+FR\s+(\d+)/,
    'PL'  => /Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+)/
  }
  
  belongs_to :source_entry, :class_name => "Entry"
  belongs_to :cited_entry,  :class_name => "Entry"
    
  def url
    case citation_type
    when 'USC'
      "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+#{part_1}USC#{part_2}"
    when 'CFR'
      "http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=#{part_1}&PART=#{part_2}&SECTION=#{part_3}&SUBPART=&TYPE=TEXT"
    when 'FR'
      "/citation/#{part_1}/#{part_2}" if part_1.to_i >= 59
    when 'PL'
      "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{part_1}_cong_public_laws&docid=f:publ#{sprintf("%03d",part_2.to_i)}.#{part_1}" if part_1.to_i >= 104
    end
  end
  
  def name
    case citation_type
    when 'USC'
      "#{part_1} U.S.C. #{part_2}"
    when 'CFR'
      "#{part_1} CFR #{part_2}" + (part_3.blank? ? '' : ".#{part_3}")
    when 'FR'
      "#{part_1} FR #{part_2}"
    when 'PL'
      "Public Law #{part_1}-#{part_2}"
    end
  end
  
  def self.extract!(entry)
    text = entry.full_text_raw
    entry.citations.delete
    return if entry.blank?
    
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
