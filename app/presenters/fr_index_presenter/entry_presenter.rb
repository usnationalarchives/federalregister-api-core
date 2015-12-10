class FrIndexPresenter
  class EntryPresenter < Struct.new(
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
  )
    include EntryViewLogic

    DEFAULT_SUBJECT_SQL = <<-SQL
      IF(public_inspection_documents.subject_3 IS NOT NULL AND public_inspection_documents.subject_3 != '',
        CONCAT(public_inspection_documents.subject_1, ' ', public_inspection_documents.subject_2),
        IF(public_inspection_documents.subject_2 IS NOT NULL AND public_inspection_documents.subject_2 != '',
          public_inspection_documents.subject_1,
          entries.toc_subject
        )
      )
    SQL
    SUBJECT_SQL = "IFNULL(entries.fr_index_subject, #{DEFAULT_SUBJECT_SQL})"
    DEFAULT_DOC_SQL = <<-SQL
      IF(public_inspection_documents.subject_3 IS NOT NULL AND public_inspection_documents.subject_3 != '',
        public_inspection_documents.subject_3,
        IF(public_inspection_documents.subject_2 IS NOT NULL AND public_inspection_documents.subject_2 != '',
          public_inspection_documents.subject_2,
          IF(public_inspection_documents.subject_1 IS NOT NULL AND public_inspection_documents.subject_1 != '',
            public_inspection_documents.subject_1,
            entries.toc_doc
          )
        )
      )
    SQL
    DOC_SQL = "IFNULL(entries.fr_index_doc, #{DEFAULT_DOC_SQL})"

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
      "https://www.gpo.gov/fdsys/pkg/FR-#{publication_date.to_s(:db)}/pdf/#{document_number}.pdf"
    end

    def public_path
      "/a/#{document_number}"
    end

    def needs_attention?(last_completed_issue)
      return false if modified?
      return true unless last_completed_issue
      last_completed_issue < publication_date
    end
  end
end
