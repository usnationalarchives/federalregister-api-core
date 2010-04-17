module EntryImporter::Sections
  extend EntryImporter::Utils
  provides :section_ids
  
  def section_ids
    Section.all.select{|s| s.cfr_titles.include?(cfr_title.to_i)}.map(&:id)
  end
  
end