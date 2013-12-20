class FrIndexPresenter
  class AgencyPresenter
    include FrIndexPresenter::Utils
    attr_reader :agency, :year, :children, :max_date

    delegate :name,
      :to_param,
      :to => :agency

    def initialize(agency, year, options={})
      @agency = agency
      @year = year.to_i
      raise ActiveRecord::RecordNotFound unless FrIndexPresenter.available_years.include?(@year)

      @children = options[:children] || []
      @entry_count = options[:entry_count]
      @needs_attention_count = options[:needs_attention_count]
      @oldest_issue_needing_attention = options[:oldest_issue_needing_attention]
      @last_published = options[:last_published]
      @max_date = parse_date(options[:max_date]) || last_issue_published
    end

    def pseudonym
      if agency.pseudonym.present?
        AgencyPseudonym.new(agency)
      end
    end

    def current_year?
      year >= Date.today.year
    end

    def last_issue
      entries.map(&:publication_date).max
    end

    def first_letter
      agency.name.chars.first
    end

    def last_completed_issue
      return @last_completed_issue if defined?(@last_completed_issue)
      @last_completed_issue = agency_status.try(:last_completed_issue)
    end

    def entry_count
      @entry_count ||= EntrySearch.new(
        :conditions => sphinx_conditions
      ).count
    end

    def document_types
      @document_types ||= EntrySearch.new(
        :conditions => sphinx_conditions
      ).type_facets.map{|f| DocumentType.new(agency, year, f.value, :max_date => max_date)}
    end

    def grouping_for_document_type_and_header(granule_class, header)
      document_type = document_types.find{|dt| dt.granule_class == granule_class}
      document_type.groupings.find{|g| g.header == header}
    end

    def needs_attention_count
      @needs_attention_count ||= calculate_needs_attention_count
    end

    def calculate_needs_attention_count
      document_types.map(&:needs_attention_count).sum
    end

    def needs_attention?
      needs_attention_count > 0
    end

    def oldest_issue_needing_attention
      return @oldest_issue_needing_attention if defined?(@oldest_issue_needing_attention)
      @oldest_issue_needing_attention = calculate_oldest_issue_needing_attention
    end

    def calculate_oldest_issue_needing_attention
      document_types.map(&:oldest_issue_needing_attention).compact.min if needs_attention?
    end

    def update_cache
      FrIndexAgencyStatus.update_cache(self)
    end


    def last_published
      @last_published ||= agency_status.try(:last_published)
    end

    def published_pdf_path
      if last_published
        "/index/pdf/#{year}/#{last_published.strftime("%m")}/#{agency.slug}.pdf"
      end
    end

    private

    def agency_status
      @agency_status ||= FrIndexAgencyStatus.find_by_year_and_agency_id(year, agency.id)
    end

    def sphinx_conditions
      {
        :agency_ids => [agency.id],
        :without_agency_ids => agency.children.map(&:id),
        :publication_date => publication_date_conditions,
      }
    end
  end
end
