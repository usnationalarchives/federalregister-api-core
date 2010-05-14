module Content
  class SectionAssignmentCloner
    def clone(date)
      
      if SectionHighlight.find_by_publication_date(date).nil?
        prior_date = Entry.first(
          :select => "publication_date",
          :conditions => ["publication_date < ?", date],
          :order => "publication_date DESC"
        ).publication_date

        SectionHighlight.find_all_by_publication_date(prior_date, :order => "position").each do |highlight|
          new_highlight = highlight.clone
          new_highlight.publication_date = date
          new_highlight.save!
        end
      end
    end
  end
end