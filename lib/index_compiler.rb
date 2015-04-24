class IndexCompiler
  attr_reader :agency_docs, :doc_data, :agency, :year

  def initialize(year, agency_id)
    @agency = Agency.find_by_id(agency_id)
    @year = year #TODO: Validate user year input
    @doc_data = {
      name: agency.try(:name),
      slug: agency.try(:slug),
      url: agency.try(:url),
      document_categories: [],
      see_also: "Stubbed See Also"
    }
  end

  def self.perform(year, agency_id)
    stubbed_obj = new(year, agency_id)
    stubbed_obj.documents
    stubbed_obj.save(stubbed_obj.doc_data)
  end

  def child_agency_ids(parent=agency) #TODO: Write unit test
    descendants = []
    parent.children.each do |child|
      descendants << child.id
      descendants << child_agency_ids(child) if child.children.present?
    end
    descendants.flatten
  end

  def entries
    @entries ||= Agency.find_as_arrays([
      "SELECT entries.document_number, entries.granule_class,
      IFNULL(entries.fr_index_subject,
        #{FrIndexPresenter::EntryPresenter::DEFAULT_SUBJECT_SQL}
       ) AS subject_1,
      IFNULL(entries.fr_index_doc,
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
      ) AS subject_2
      FROM entries

      JOIN public_inspection_documents
      ON public_inspection_documents.document_number = entries.document_number
      JOIN agency_assignments
      ON agency_assignments.assignable_id = entries.id AND agency_assignments.assignable_type = 'Entry'
      JOIN agencies
      ON agencies.id = agency_assignments.agency_id
      WHERE entries.publication_date >= ? AND
       entries.publication_date <= ?
       AND agencies.id IN(?)",
       "#{year}-01-01",
       "#{year}-12-31",
       ([agency.id] + child_agency_ids).join(",")
    ]).group_by{|e|e[1]}
  end

  def documents
    puts "Number of doc types: #{entries.size}"
    puts entries.keys
    entries.each do |doc_type, doc_representations|
      @doc_data[:document_categories] << {
        name: doc_type,
        documents: process_entries(doc_representations)
      }
    end
  end

  def process_entries(entries)
    entries.map do |doc_representation|
      {
        subject_1: doc_representation[2],
        subject_2: doc_representation[3],
        document_numbers: doc_representation[0]
      }
    end
  end


  def save(document_data)
    FileUtils.mkdir_p(json_index_dir)

    File.open json_index_path, 'w' do |f|
      f.write(document_data.to_json)
    end
  end

  private

  def json_index_path
    "data/fr_index/2015/sample_agency.json" #TODO: Stubbed
  end

  def json_index_dir
    "data/fr_index/2015/" #TODO: Stubbed
  end

end
