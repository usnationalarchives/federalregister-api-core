class IndexCompiler
  attr_reader :agency_docs, :doc_data, :agency, :year, :path_manager

  DEFAULT_SUBJECT_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_SUBJECT_SQL
  SUBJECT_SQL = FrIndexPresenter::EntryPresenter::SUBJECT_SQL
  DEFAULT_DOC_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_DOC_SQL
  DOC_SQL = FrIndexPresenter::EntryPresenter::DOC_SQL

  def initialize(year, agency_id)
    @agency = Agency.find_by_id(agency_id)
    @year = year
    @path_manager = FileSystemPathManager.new("#{year}-01-01")
    @doc_data = {
      name: agency.try(:name),
      slug: agency.try(:slug),
      url: agency.try(:url),
      document_categories: [],
      see_also: process_see_also
    }
  end

  def self.perform(year, agency_id)
    agency_representation = new(year, agency_id)
    agency_representation.process_entries
    agency_representation.save(agency_representation.doc_data)
  end

  def child_agency_ids(parent=agency)
    descendants = []
    parent.children.each do |child|
      descendants << child.id
      descendants << child_agency_ids(child) if child.children.present?
    end
    descendants.flatten
  end

  def entries
    @entries ||= Agency.find_as_arrays([
     "SELECT
        entries.document_number,
        entries.granule_class,
        #{SUBJECT_SQL} AS subject_1,
        #{DOC_SQL} AS subject_2
      FROM entries
      JOIN public_inspection_documents
        ON public_inspection_documents.document_number = entries.document_number
      JOIN agency_assignments
        ON agency_assignments.assignable_id = entries.id AND agency_assignments.assignable_type = 'Entry'
      JOIN agencies
        ON agencies.id = agency_assignments.agency_id
      WHERE
        entries.publication_date >= ? AND
        entries.publication_date <= ? AND
        agencies.id IN(?)",

      "#{year}-01-01",
      "#{year}-12-31",
      ([agency.id] + child_agency_ids).join(",")
    ]).
    group_by{|entry|entry[1]}
  end

  def process_see_also
    agency.children.map do |child_agency|
      {
        name: child_agency.name,
        slug: child_agency.slug
      }
    end
  end

  def process_entries
    entries.each do |doc_type, doc_representations|
      @doc_data[:document_categories] << {
        name: doc_type,
        documents: process_documents(doc_representations).
          sort_by{|k,v|[k[:subject_1],k[:subject_2]]}
      }
    end
  end

  def process_documents(doc_representations)
    doc_representations.map do |doc_representation|
      [document_number, granule_class , subject_1, subject_2]
      if doc_representation[2].blank?
        {
          subject_1: doc_representation[3],
          subject_2: "",
          document_numbers: doc_representation[0]
        }
      else
        {
          subject_1: doc_representation[2],
          subject_2: doc_representation[3],
          document_numbers: doc_representation[0]
        }
      end
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
    "data/fr_index/2015/#{agency.slug}.json"
  end

  def json_index_dir
    path_manager.index_json_dir
  end

end
