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

  include Utils

  attr_reader :year, :max_date

  def self.available_years
    min_year = Rails.env == 'development' ? 2012 : 2013
    (min_year..Date.today.year).to_a.uniq.reverse
  end

  def initialize(year, options = {})
    @year = year.to_i
    @max_date = parse_date(options[:max_date]) || last_issue_published
    @last_published = options[:last_published]

    raise ActiveRecord::RecordNotFound unless FrIndexPresenter.available_years.include?(@year)
  end

  def agencies_by_letter
    agencies_with_pseudonyms.group_by(&:first_letter)
  end

  def agencies
    return @agency_years if @agency_years

    agencies = ::Agency.all(
      :conditions => {:id => raw_entry_counts_by_agency_id.keys},
      :include => :children
    ).sort_by{|agency| agency.name.downcase}

    @agency_years = agencies.map do |agency|
      children = agencies.
        select{|candidate_child| candidate_child.parent_id == agency.id}.
        sort_by{|child| child.name.downcase}.
        map do |child|
          Agency.new(
            child,
            year,
            :entry_count => raw_entry_counts_by_agency_id[child.id],
            :needs_attention_count => needs_attention_counts_by_agency_id[child.id],
            :oldest_issue_needing_attention => oldest_issue_needing_attention_by_agency_id[child.id],
            :max_date => max_date
          )
      end

      entry_count = children.present? ? nil : raw_entry_counts_by_agency_id[agency.id]
      Agency.new(agency, year,
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
    entries_scope.maximum(:end_page)
  end

  def max_issue_number
    entries_scope.maximum(:issue_number)
  end

  def last_published
    @last_published ||= FrIndexAgencyStatus.scoped(:conditions => {:year => year}).maximum(:last_published)
  end

  def published_pdf_path
    if last_published
      "/index/pdf/#{year}/#{last_published.strftime("%m")}.pdf"
    end
  end

  private

  def raw_entry_counts_by_agency_id
    @raw_entry_counts_by_agency_id ||= EntrySearch.new(
      :conditions => {:publication_date => publication_date_conditions}
    ).agency_facets.inject({}) do |hsh, facet|
      hsh[facet.value] = facet.count
      hsh
    end
  end

  def needs_attention_counts_by_agency_id
    @needs_attention_counts_by_agency_id ||= Hash[FrIndexAgencyStatus.find_as_arrays(
      :select => "agency_id, needs_attention_count",
      :conditions => {:year => year}
    ).map{|id, count| [id.to_i, count.to_i]}]
  end

  def oldest_issue_needing_attention_by_agency_id
    @oldest_issue_needing_attention_by_agency_id ||= Hash[FrIndexAgencyStatus.find_as_arrays(
      :select => "agency_id, oldest_issue_needing_attention",
      :conditions => {:year => year}
    ).map{|id, date| [id.to_i, date ? Date.parse(date) : nil]}]
  end

  AgencyPseudonym = Struct.new(:agency) do
    def name
      agency.pseudonym
    end

    def see_instead
      agency
    end

    def entry_count
      0
    end

    def first_letter
      name.chars.first
    end
  end

  class Agency
    include Utils
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
      entries.
        group_by(&:granule_class).
        sort_by{|type,entries| type}.
        reverse.
        map {|type, entries| DocumentType.new(self, type, entries) }
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

    def entry_ids
      @entry_ids ||= EntrySearch.new(
        :conditions => sphinx_conditions,
        :per_page => 2000
      ).result_ids
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

    def entries
      return @entries if @entries

      results = ::Entry.connection.select_all(<<-SQL)
        SELECT entries.id,
          entries.title,
          entries.document_number,
          entries.publication_date,
          IFNULL(public_inspection_documents.toc_subject, entries.toc_subject) AS original_subject,
          IFNULL(IFNULL(public_inspection_documents.toc_doc, entries.toc_doc), entries.title) AS original_doc,
          entries.fr_index_subject AS modified_subject,
          entries.fr_index_doc AS modified_doc,
          entries.granule_class,
          entries.start_page,
          entries.end_page,
          comment_close_events.date AS comments_close_on,
          SUM(regulatory_plans.priority_category IN (#{RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES.map(&:inspect).join(',')})) > 0 AS significant,
          entries.regulations_dot_gov_docket_id AS docket_id
          # IFNULL(dockets.comments_count,0) AS comment_count
        FROM entries
        LEFT OUTER JOIN public_inspection_documents
          ON public_inspection_documents.entry_id = entries.id
        # LEFT OUTER JOIN dockets
          # ON dockets.id = entries.regulations_dot_gov_docket_id
        LEFT OUTER JOIN events AS comment_close_events
          ON comment_close_events.entry_id = entries.id
          AND comment_close_events.event_type = 'CommentsClose'
        LEFT OUTER JOIN entry_regulation_id_numbers
          ON entry_regulation_id_numbers.entry_id = entries.id
        LEFT OUTER JOIN regulatory_plans
          ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number
          AND regulatory_plans.current = 1
        WHERE entries.id IN (#{entry_ids.join(',')})
        GROUP BY entries.id
      SQL

      docket_ids = results.map{|r| r['docket_id']}.compact.uniq

      if docket_ids.present?
        comment_counts = Docket.find_as_hash(:select => "id, comments_count", :conditions => {:id => docket_ids})
      else
        comment_counts = {}
      end

      @entries = results.map{|row| Entry.new(row.merge('comment_count' => comment_counts[row.delete('docket_id')] || 0)) }
    end
  end

  Entry = Struct.new(
      :id,
      :title,
      :document_number,
      :publication_date,
      :original_subject,
      :modified_subject,
      :original_doc,
      :modified_doc,
      :granule_class,
      :start_page,
      :end_page,
      :comments_close_on,
      :significant,
      :comment_count
    ) do
    
    include EntryViewLogic

    def initialize(options)
      # manual typecasting FTW
      %w(publication_date comments_close_on).each do |date_attr|
        val = options[date_attr]
        if val && val.is_a?(String)
          options[date_attr] = Date.parse(val)
        end
      end

      %w(comment_count start_page end_page).each do |int_attr|
        val = options[int_attr]
        options[int_attr] = val.to_i if val
      end

      # populate struct
      options.each do |key, val|
        self[key] = val
      end
    end

    def fr_index_subject
      modified_subject || original_subject
    end

    def fr_index_doc
      modified_doc || original_doc
    end

    def comments_open?
      comments_close_on.present? && comments_close_on >= Date.today
    end

    def significant?
      significant == '1'
    end

    def modified?
      modified_subject || modified_doc
    end

    def pdf_url
      "http://www.gpo.gov/fdsys/pkg/FR-#{publication_date.to_s(:db)}/pdf/#{document_number}.pdf"
    end

    def public_path
      "/a/#{document_number}"
    end
  end

  class DocumentType
    attr_reader :agency_year, :granule_class, :entries
    delegate :last_completed_issue, :to => :agency_year

    def initialize(agency_year, granule_class, entries)
      @agency_year = agency_year
      @granule_class = granule_class
      @entries = entries
    end

    def name
      ::Entry::ENTRY_TYPES[granule_class]
    end

    def entry_count
      entries.count
    end

    def grouping_count
      groupings.count
    end

    def groupings
      @groupings ||= (subject_groupings + document_groupings).sort_by{|grouping| grouping.header.downcase}
    end

    def needs_attention_count
      groupings.sum(&:needs_attention_count)
    end

    def needs_attention?
      needs_attention_count > 0
    end

    def oldest_issue_needing_attention
      groupings.map(&:oldest_issue_needing_attention).compact.min if needs_attention?
    end

    private

    def subject_groupings
      entries.
        reject{|e| e.fr_index_subject.blank?}.
        group_by(&:fr_index_subject).
        map {|fr_index_subject, group_entries| SubjectGrouping.new(self, fr_index_subject, group_entries) }
    end

    def document_groupings
      entries.
        select{|e| e.fr_index_subject.blank?}.
        group_by(&:fr_index_doc).
        map {|fr_index_doc, group_entries| DocumentGrouping.new(self, fr_index_doc, group_entries) }
    end
  end

  class SubjectGrouping
    attr_reader :document_type, :header, :entries
    delegate :last_completed_issue,
      :granule_class,
      :to => :document_type

    def initialize(document_type, header, entries)
      @document_type = document_type
      @header = header
      @entries = entries
    end

    def document_groupings
      entries.
        group_by(&:fr_index_doc).
        sort_by{|fr_index_doc, group_entries| fr_index_doc.downcase }.
        map {|fr_index_doc, group_entries| DocumentGrouping.new(self, fr_index_doc, group_entries, header) }
    end

    def identifier
      "#{granule_class}_#{Digest::MD5.hexdigest(header)}"
    end

    def needs_attention_count
      @needs_attention_count = document_groupings.map(&:needs_attention_count).sum
    end

    def needs_attention?
      needs_attention_count > 0
    end

    def oldest_issue_needing_attention
      document_groupings.map(&:oldest_issue_needing_attention).compact.min if needs_attention?
    end

    def header_attribute
      'fr_index_subject'
    end
  end

  class DocumentGrouping
    attr_reader :parent, :header, :entries, :fr_index_subject
    delegate :last_completed_issue,
      :granule_class,
      :to => :parent

    def initialize(parent, header, entries, fr_index_subject = nil)
      @parent = parent
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
      entries.any?{|e| e.comment_count > 0}
    end

    def significant?
      entries.any?(&:significant?) 
    end

    def needs_attention_count
      needs_attention? ? 1 : 0
    end

    def needs_attention?
      old_entry_count == 0 && unmodified?
    end

    def oldest_issue_needing_attention
      entries.map(&:publication_date).min if needs_attention?
    end

    def identifier
      "#{granule_class}_#{Digest::MD5.hexdigest(header)}"
    end

    def top_level_header
      top_level? ? header : fr_index_subject
    end
   
    def top_level?
      fr_index_subject.blank?
    end

    def header_attribute
      'fr_index_doc'
    end

    private

    def old_entry_count
      date = last_completed_issue
      if date
        entries.select{|e| e.publication_date <= date}.size
      else
        0
      end
    end

    def unmodified?
      entries.none?(&:modified?)
    end
  end
end
