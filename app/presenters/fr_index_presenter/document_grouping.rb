class FrIndexPresenter
  class DocumentGrouping
    attr_reader :parent, :header, :entries, :fr_index_subject
    include ApplicationHelper
    delegate :last_completed_issue,
      :granule_class,
      :entry_ids_for_year,
      :to => :parent

    def initialize(parent, header, entries, fr_index_subject = nil)
      @parent = parent
      @header = header || entries.first.title
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
      entries.any? { |entry| entry.needs_attention?(last_completed_issue) }
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

    def cfr_index_reference
      "(#{[eo_cfr_index_reference, proclamation_cfr_index_reference].compact.join('; ')})"
    end

    def parenthetical_citation
      document_type_citations = []

      entries.group_by(&:presidential_document_type_id).each do |id, entries|
        presidential_document_type = PresidentialDocumentType.find(id)
        if presidential_document_type.present?
          document_type_citations << presidential_document_type.entry_collection_formatter.call(entries)
        else
          document_type_citations << "#{pluralize_without_count(entries.count, 'Presidential Document')} #{entries.map{|x| 'p. '}.join(', ')}"
        end
      end

      document_type_citations.join('; ')
    end

  end
end
