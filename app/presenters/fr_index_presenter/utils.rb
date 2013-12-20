class FrIndexPresenter
  module Utils
    def publication_date_conditions
      if max_date.present?
        {:gte => "#{year}-01-01", :lte => max_date.to_s(:iso)}
      else
        {:year => year}
      end
    end

    def parse_date(date_or_str)
      return unless date_or_str.present?
      date_or_str.is_a?(Date) ? date_or_str : Date.parse(date_or_str)
    end

    def last_issue_published
      ::Entry.scoped(:conditions => "publication_date BETWEEN '#{year}-01-01' AND '#{year}-12-31'").maximum(:publication_date)
    end

    private

    def entries_scope
      ::Entry.scoped(:conditions => "publication_date BETWEEN '#{year}-01-01' AND '#{max_date.to_s(:db)}'")
    end
  end
end
