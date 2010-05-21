module Content::EntryImporter::Sections
  extend Content::EntryImporter::Utils
  provides :section_ids
  
  def section_ids
    Section.all.select{|s| s.cfr_citation_ranges.any?{|range| range.include?(cfr_title, cfr_part)}}.map(&:id)
  end
end