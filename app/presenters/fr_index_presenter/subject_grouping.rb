class FrIndexPresenter
  class SubjectGrouping
    attr_reader :document_type, :header, :entries
    delegate :last_completed_issue,
      :granule_class,
      :entry_ids_for_year,
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
end
