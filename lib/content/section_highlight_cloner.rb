module Content
  class SectionHighlightCloner
    def clone(date)
      if SectionHighlight.find_by_publication_date(date).nil?
        prior_date = Entry.
          select("publication_date").
          where("publication_date < ?", date).
          order("publication_date DESC").
          first.
          publication_date

        SectionHighlight.
          where("publication_date = ? && position <= 6", prior_date).
          order(:position).
          each do |highlight|
            new_highlight = highlight.clone
            new_highlight.publication_date = date
            new_highlight.save!
          end
      end
    end
  end
end
