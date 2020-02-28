module Content
  class SectionHighlightCloner
    def clone(date)
      return if SectionHighlight.where(publication_date: date).exists?
      
      prior_date = SectionHighlight.where("publication_date < ?", date).maximum(:publication_date)

      SectionHighlight.
        where("publication_date = ? && position <= 6", prior_date).
        order(:position).
        each do |highlight|
          new_highlight = highlight.dup
          new_highlight.publication_date = date
          new_highlight.save!
        end
    end
  end
end
