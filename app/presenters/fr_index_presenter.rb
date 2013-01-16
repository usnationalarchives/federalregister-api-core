class FrIndexPresenter
  LAST_CURATED = 3.days.ago.to_date

  attr_reader :year

  def self.available_years
    [2013, 2012]
  end

  def initialize(year)
    @year = year.to_i
    raise ActiveRecord::RecordNotFound unless FrIndexPresenter.available_years.include?(@year)
  end

  def agencies_by_letter
    agencies.group_by(&:first_letter)
  end

  def agencies
    return @agency_years if @agency_years

    agencies = Agency.all(
      :conditions => {:id => raw_counts_by_agency_id.keys},
      :include => :children
    )

    @agency_years = agencies.map do |agency|
      children = agencies.
        select{|candidate_child| candidate_child.parent_id == agency.id}.
        sort_by{|child| child.name.downcase}.
        map{|child| AgencyYear.new(child, year, :entry_count => raw_counts_by_agency_id[child.id]) }

      entry_count = children.present? ? nil : raw_counts_by_agency_id[agency.id]
      AgencyYear.new(agency, year,
        :children => children,
        :entry_count => entry_count
      )
    end
  end

  private

  def raw_counts_by_agency_id
    @raw_counts_by_agency_id ||= EntrySearch.new(
      :conditions => {:publication_date => {:year => year}}
    ).agency_facets.inject({}) do |hsh, facet|
      hsh[facet.value] = facet.count
      hsh
    end
  end

  class AgencyYear
    attr_reader :agency, :year, :children

    delegate :name,
      :to_param,
      :to => :agency

    def initialize(agency, year, options={})
      @agency = agency
      @year = year.to_i
      raise ActiveRecord::RecordNotFound unless FrIndexPresenter.available_years.include?(@year)

      @children = options[:children] || []
      @entry_count = options[:entry_count]
    end

    def current_year?
      year >= Date.today.year
    end

    def first_letter
      agency.name.chars.first
    end

    def entry_count
      @entry_count ||= EntrySearch.new(
        :conditions => {
          :publication_date => {:year => year},
          :agency_ids => [agency.id],
          :without_agency_ids => agency.children.map(&:id)
        }
      ).count
    end

    def document_types
      entries.
        group_by(&:granule_class).
        sort_by{|type,entries| type}.
        reverse.
        map {|type, entries| DocumentType.new(type, entries) }
    end

    def grouping_for_document_type_and_header(granule_class, header)
      document_type = document_types.find{|dt| dt.granule_class == granule_class}
      document_type.groupings.find{|g| g.header == header}
    end
    
    private

    def entries
      EntrySearch.new(
        :conditions => {
          :agency_ids => [agency.id],
          :without_agency_ids => agency.children.map(&:id),
          :publication_date => {:year => year},
        },
        :per_page => 1000
      ).chainable_results(
        :select => %w(
          id
          document_number
          publication_date
          title
          toc_subject
          toc_doc
          fr_index_subject
          fr_index_doc
          granule_class
          start_page
          end_page
          regulations_dot_gov_docket_id
          presidential_document_type_id
          executive_order_number
        ).map{|attribute| "entries.#{attribute}"}.join(",")
      ).preload(
        :docket
      )
    end
  end

  class DocumentType
    attr_reader :granule_class, :entries
    def initialize(granule_class, entries)
      @granule_class = granule_class
      @entries = entries
    end

    def name
      Entry::ENTRY_TYPES[granule_class]
    end

    def entry_count
      entries.count
    end

    def grouping_count
      groupings.count
    end

    def groupings
      (subject_groupings + document_groupings).sort_by(&:header)
    end

    private

    def subject_groupings
      entries.
        reject{|e| e.fr_index_subject.blank?}.
        group_by(&:fr_index_subject).
        map {|fr_index_subject, group_entries| SubjectGrouping.new(fr_index_subject, group_entries) }
    end

    def document_groupings
      entries.
        select{|e| e.fr_index_subject.blank?}.
        group_by(&:fr_index_doc).
        map {|fr_index_doc, group_entries| DocumentGrouping.new(fr_index_doc, group_entries) }
    end
  end

  class SubjectGrouping
    attr_reader :header, :entries

    def initialize(header, entries)
      @header = header
      @entries = entries
    end

    def document_groupings
      entries.
        group_by(&:fr_index_doc).
        sort_by{|fr_index_doc, group_entries| fr_index_doc }.
        map {|fr_index_doc, group_entries| DocumentGrouping.new(fr_index_doc, group_entries, header) }
    end

    def identifier
      Digest::MD5.hexdigest(header)
    end
  end

  class DocumentGrouping
    attr_reader :header, :entries, :fr_index_subject
    def initialize(header, entries, fr_index_subject = nil)
      @header = header
      @entries = entries
      @fr_index_subject = fr_index_subject
    end

    def entry_count
      @entries.count
    end

    def comments_open?
      entries.any?(&:comments_open?)
    end

    def has_comments?
      entries.any?{|e| (e.docket.try(:comments_count) || 0) > 0}
    end

    def significant?
      entries.any?(&:significant?) 
    end

    def needs_attention?
      old_entry_count == 0 && unmodified?
    end

    def identifier
      Digest::MD5.hexdigest(top_level_header)
    end

    def top_level_header
      top_level? ? header : fr_index_subject
    end
   
    def top_level?
      fr_index_subject.blank?
    end

    private

    def old_entry_count
      entries.select{|e| e.publication_date <= LAST_CURATED}.size
    end

    def unmodified?
      entries.none?{|e| e[:fr_index_doc] || e[:fr_index_subject]}
    end
  end
end
