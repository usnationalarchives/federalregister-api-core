ThinkingSphinx::Index.define :public_inspection_document, :with => :active_record do
  # fields
  indexes <<-SQL, :as => :title
    CONCAT(
      IFNULL(public_inspection_documents.subject_1, ''),
      ' ',
      IFNULL(public_inspection_documents.subject_2, ''),
      ' ',
      IFNULL(public_inspection_documents.subject_3, '')
    )
  SQL
  indexes "CONCAT('#{FileSystemPathManager.data_file_path}/public_inspection/raw/', public_inspection_documents.document_file_path, '.txt')", :as => :full_text, :file => true
  indexes "GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')", :as => :docket_id

  # attributes
  has "CRC32(document_number)", :as => :document_number, :type => :integer
  has "public_inspection_documents.id", :as => :public_inspection_document_id, :type => :integer
  has "CRC32(IF(public_inspection_documents.granule_class = 'SUNSHINE', 'NOTICE', public_inspection_documents.granule_class))", :as => :type, :type => :integer
  has agency_assignments(:agency_id), :as => :agency_ids
  has publication_date
  has filed_at
  has special_filing

  join docket_numbers

  join public_inspection_issues


  set_property :field_weights => {
    "title" => 100,
    "full_text" => 25,
    "agency_name" => 10
  }


  if AppConfig.sphinx.use_local_pil_date
    where <<-SQL
      public_inspection_postings.issue_id =
        (
          SELECT id
          FROM public_inspection_issues
          WHERE published_at >= #{AppConfig.sphinx.pil_index_since_date}
          ORDER BY publication_date DESC
          LIMIT 1
        )
      AND (
        publication_date IS NULL
        OR publication_date > #{AppConfig.sphinx.pil_index_since_date}
      )
    SQL
  else
    where <<-SQL
      public_inspection_postings.issue_id =
        (
          SELECT id
          FROM public_inspection_issues
          WHERE published_at IS NOT NULL
          ORDER BY publication_date DESC
          LIMIT 1
        )
      AND (
        public_inspection_documents.publication_date IS NULL
        OR public_inspection_documents.publication_date > (
          SELECT MAX(publication_date)
          FROM issues
          WHERE issues.completed_at IS NOT NULL
        )
      )
    SQL
  end
end
