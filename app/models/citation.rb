class Citation < ApplicationModel
  CITATION_TYPES = {
    'USC' => /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/,
    'CFR' => /(\d+)\s+CFR\s+(\d+)(?:\.(\d+))?/,
    'FR'  => /(\d+)\s+FR\s+(\d+)/,
    'FR-DocNum' => /(?:FR Doc(?:\.|ument)? )([A-Z0-9]+-[0-9]+)(?:[,;\. ])/i,
    'PL'  => /Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+)/,
    'EO'  => /(?:EO|E\.O\.|Executive Order) (\d+)/
  }
  
  belongs_to :source_entry, :class_name => "Entry"
  belongs_to :cited_entry,  :class_name => "Entry", :counter_cache => "citing_entries_count"
    
  def url
    case citation_type
    when 'USC'
      "https://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+#{part_1}USC#{part_2}"
    when 'CFR'
      "https://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=#{part_1}&PART=#{part_2}&SECTION=#{part_3}&SUBPART=&TYPE=TEXT"
    when 'FR'
      "/citation/#{part_1}/#{part_2}" if part_1.to_i >= 59
    when 'FR-DocNum'
      "/a/#{part_1}"
    when 'PL'
      "https://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{part_1}_cong_public_laws&docid=f:publ#{sprintf("%03d",part_2.to_i)}.#{part_1}" if part_1.to_i >= 104
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
    when 'FR-DocNum'
      "FR Doc. #{part_1}"
    when 'PL'
      "Public Law #{part_1}-#{part_2}"
    when 'EO'
      "Executive Order #{part_1}"
    end
  end
  
  def self.extract!(entry)
    text = entry.full_text
    return [] if text.blank?

    citations = []

    CITATION_TYPES.each_pair do |citation_type, regexp|
      text.scan(regexp) do |part_1, part_2, part_3|
        attributes = {:source_entry_id => entry.id, :citation_type => citation_type, :part_1 => part_1, :part_2 => part_2, :part_3 => part_3}
        
        citation = Citation.first(:conditions => attributes)
        
        if citation.nil?
          citation = Citation.new(attributes)
          
          if citation_type == 'FR' && part_1.to_i >= 59
            citation.matching_fr_entries(entry.agencies).each do |cited_entry|
              citation = Citation.new(attributes)
              citation.cited_entry = cited_entry
              citations << citation
            end
          else
            citations << citation
          end
        end
      end
    end

    citations
  end

  def matching_fr_entries(agencies=[])
    @matching_fr_entries ||= case citation_type
                             when 'FR'
                               Entry.find_best_citation_matches(part_1, part_2, agencies)
                             when 'FR-DocNum'
                               Entry.find_by_document_number(part_1)
                             when 'EO'
                               Entry.find_all_by_presidential_document_type_id_and_executive_order_number(
                                 PresidentialDocumentType::EXECUTIVE_ORDER.id,
                                 part_1
                               )
                             end
  end
end
