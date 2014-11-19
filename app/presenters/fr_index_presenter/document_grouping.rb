class FrIndexPresenter
  class DocumentGrouping
    attr_reader :parent, :header, :entries, :fr_index_subject
    delegate :last_completed_issue,
      :granule_class,
      :entry_ids_for_year,
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
  end
end
