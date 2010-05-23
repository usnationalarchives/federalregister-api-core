module Content::EntryImporter::Sections
  extend Content::EntryImporter::Utils
  provides :section_ids
  
  def section_ids
    Section.all.select{|s| s.should_include_entry?(entry)}.map(&:id)
  end
end