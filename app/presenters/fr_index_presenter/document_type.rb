class FrIndexPresenter
  class DocumentType
    attr_reader :agency, :year, :granule_class, :max_date, :unapproved_only
    delegate :last_completed_issue, :to => :agency_year

    include FrIndexPresenter::Utils

    def initialize(agency, year, granule_class, options={})
      @agency = agency
      @year = year
      @granule_class = granule_class.upcase
      @max_date = parse_date(options[:max_date]) || last_issue_published
      @unapproved_only = options[:unapproved_only].present?
    end

    def agency_year
      @agency_year ||= AgencyPresenter.new(agency, year)
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

    def entry_ids_for_year
      @entry_ids_for_year ||= Entry.search_klass.new(
        :conditions => es_conditions.merge(:publication_date => {:year => year}),
        :maximum_per_page => 10000,
        :per_page => 10000
      ).result_ids
    end

    def grouping_for_header(header)
      groupings.find{|g| g.header == header}
    end

    private

    def entry_ids
      Entry.search_klass.new(
        :conditions => es_conditions,
        :maximum_per_page => 10000,
        :per_page => 10000
      ).result_ids
    end

    def es_conditions
      {
        :agency_ids => [agency.id],
        :without_agency_ids => agency.children.map(&:id),
        :publication_date => publication_date_conditions,
        :type => granule_class
      }
    end

    def entries
      return @entries if @entries

      ids = entry_ids

      if ids.empty?
        return @entries = []
      end

      results = ::Entry.connection.select_all(<<-SQL)
        SELECT entries.id,
          MAX(entries.title) AS title,
          MAX(entries.document_number) AS document_number,
          MAX(entries.publication_date) AS publication_date,
          #{FrIndexPresenter::EntryPresenter::DEFAULT_SUBJECT_SQL} AS original_subject,
          #{FrIndexPresenter::EntryPresenter::DEFAULT_DOC_SQL} AS original_doc,
          MAX(entries.fr_index_subject) AS modified_subject,
          MAX(entries.fr_index_doc) AS modified_doc,
          MAX(entries.granule_class) AS granule_class,
          MAX(entries.start_page) AS start_page,
          MAX(entries.end_page) AS end_page,
          IF(MAX(entries.presidential_document_type_id) = #{PresidentialDocumentType::EXECUTIVE_ORDER.id}, MAX(entries.presidential_document_number), NULL) AS executive_order_number,
          MAX(entries.presidential_document_type_id) AS presidential_document_type_id,
          IF(MAX(entries.presidential_document_type_id) = #{PresidentialDocumentType::PROCLAMATION.id}, MAX(entries.presidential_document_number), NULL) AS proclamation_number,
          MAX(entries.signing_date) AS signing_date,
          MAX(comment_close_events.date) AS comments_close_on,
          SUM(regulatory_plans.priority_category IN (#{RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES.map(&:inspect).join(',')})) > 0 AS significant,
          MAX(entries.regulations_dot_gov_docket_id) AS docket_id
        FROM entries
        LEFT OUTER JOIN public_inspection_documents
          ON public_inspection_documents.entry_id = entries.id
        LEFT OUTER JOIN events AS comment_close_events
          ON comment_close_events.entry_id = entries.id
          AND comment_close_events.event_type = 'CommentsClose'
        LEFT OUTER JOIN entry_regulation_id_numbers
          ON entry_regulation_id_numbers.entry_id = entries.id
        LEFT OUTER JOIN regulatory_plans
          ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number
          AND regulatory_plans.current = 1
        WHERE entries.id IN (#{ids.join(',')})
        GROUP BY entries.id
      SQL

      docket_ids = results.map{|r| r['docket_id']}.compact.uniq

      if docket_ids.present?
        sql = RegsDotGovDocket.select("id, comments_count").where(id: docket_ids).to_sql
        comment_counts = RegsDotGovDocket.find_as_hash(sql)
      else
        comment_counts = {}
      end

      @entries = results.map{|row| EntryPresenter.new(row.merge('comment_count' => comment_counts[row.delete('docket_id')] || 0)) }
    end

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
end
