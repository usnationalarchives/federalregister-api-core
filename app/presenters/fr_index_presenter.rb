class FrIndexPresenter
  include FrIndexPresenter::Utils

  attr_reader :max_date, :path_manager, :unapproved_only, :year 

  def self.available_years
    min_year = Rails.env == 'development' ? 2012 : 2013
    (min_year..Date.today.year).to_a.uniq.reverse
  end

  def initialize(year, options = {})
    @year = year.to_i
    @max_date = parse_date(options[:max_date]) || last_issue_published
    @last_published = options[:last_published]

    @path_manager = FileSystemPathManager.new("#{year}-01-01")

    raise ActiveRecord::RecordNotFound unless FrIndexPresenter.available_years.include?(@year)
  end

  def agencies_by_letter
    agencies_with_pseudonyms.group_by(&:first_letter)
  end

  def agencies
    return @agency_years if @agency_years

    agencies = ::Agency.
      where(id: raw_entry_counts_by_agency_id.keys).
      includes(:children).
      sort_by{|agency| agency.name.downcase}

    @agency_years = agencies.map do |agency|
      children = agencies.
        select{|candidate_child| candidate_child.parent_id == agency.id}.
        sort_by{|child| child.name.downcase}.
        map do |child|
          AgencyPresenter.new(
            child,
            year,
            :entry_count => raw_entry_counts_by_agency_id[child.id],
            :needs_attention_count => needs_attention_counts_by_agency_id[child.id],
            :oldest_issue_needing_attention => oldest_issue_needing_attention_by_agency_id[child.id],
            :max_date => max_date
          )
      end

      entry_count = children.present? ? nil : raw_entry_counts_by_agency_id[agency.id]
      AgencyPresenter.new(agency, year,
        :children => children,
        :entry_count => entry_count,
        :needs_attention_count => needs_attention_counts_by_agency_id[agency.id],
        :oldest_issue_needing_attention => oldest_issue_needing_attention_by_agency_id[agency.id],
        :max_date => max_date
      )
    end
  end

  def agencies_with_pseudonyms
    (agencies + agencies.map(&:pseudonym)).compact.sort_by{|agency_or_pseudonym| agency_or_pseudonym.name.downcase}
  end

  def volume_number
    entries_scope.maximum(:volume)
  end

  def max_page_number
    max_page_number = entries_scope.maximum(:end_page)
    if max_page_number.odd?
      max_page_number + 1
    else
      max_page_number
    end
  end

  def max_issue_number
    entries_scope.maximum(:issue_number)
  end

  def last_published
    @last_published ||= FrIndexAgencyStatus.scoped(:conditions => {:year => year}).maximum(:last_published)
  end

  def published_pdf_path
    if last_published
      path_manager.index_pdf_path(last_published)
    end
  end

  private

  def raw_entry_counts_by_agency_id
    @raw_entry_counts_by_agency_id ||= Entry.search_klass.new(
      :conditions => {:publication_date => publication_date_conditions}
    ).agency_facets.inject({}) do |hsh, facet|
      hsh[facet.value] = facet.count
      hsh
    end
  end

  def needs_attention_counts_by_agency_id
    sql_array = ["SELECT agency_id, needs_attention_count FROM fr_index_agency_statuses WHERE year = ?", year]

    @needs_attention_counts_by_agency_id ||= Hash[ FrIndexAgencyStatus.find_as_arrays(sql_array) ]
  end

  def oldest_issue_needing_attention_by_agency_id
    sql_array = ["SELECT agency_id, oldest_issue_needing_attention FROM fr_index_agency_statuses WHERE year = ?", year]

    @oldest_issue_needing_attention_by_agency_id ||= Hash[ FrIndexAgencyStatus.find_as_arrays(sql_array) ]
  end
end
