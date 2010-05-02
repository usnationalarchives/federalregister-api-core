module Content::EntryImporter::ReferencedDates
  extend Content::EntryImporter::Utils
  provides :referenced_dates
  
  def referenced_dates
    referenced_dates = []
    %w(effectiveDate commentDate).each do |date_tag_name|
      date = mods_node.css(date_tag_name).first.try(:content)
      if date
        referenced_dates << ReferencedDate.new(:date => date, :date_type => type)
      end
    end
    
    referenced_dates
  end
end