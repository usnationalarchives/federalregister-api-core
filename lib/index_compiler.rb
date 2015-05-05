class IndexCompiler
  attr_reader :doc_data, :agency, :year, :path_manager

  DEFAULT_SUBJECT_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_SUBJECT_SQL
  SUBJECT_SQL = FrIndexPresenter::EntryPresenter::SUBJECT_SQL
  DEFAULT_DOC_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_DOC_SQL
  DOC_SQL = FrIndexPresenter::EntryPresenter::DOC_SQL

  def initialize(year, agency_id)
    @agency = Agency.find(agency_id)
    @year = year.to_i
    @path_manager = FileSystemPathManager.new("#{year}-01-01")
    @doc_data = {
      name: agency.try(:name),
      slug: agency.try(:slug),
      url: agency.try(:url),
      document_categories: []
    }
  end

  def self.perform(date)
    date = date.is_a?(Date) ? date : Date.parse(date)
    year = date.strftime('%Y')
    Agency.all.each do |agency|
      IndexCompiler.process_agency_with_docs(year, agency.id)
    end
  end

  def self.process_agency_with_docs(year, agency_id)
    agency_representation = new(year, agency_id)
    if agency_representation.any_documents?
      agency_representation.process_entries
      agency_representation.process_see_also
      agency_representation.save(agency_representation.ordered_json)
    end
  end

  def descendant_agency_ids(parent=agency)
    descendants = []
    parent.children.each do |child|
      descendants << child.id
      descendants << descendant_agency_ids(child) if child.children.present?
    end
    descendants.flatten
  end

  def entries
    @entries ||= Agency.find_as_hashes([
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
      ([agency.id] + descendant_agency_ids).join(",")
    ]).
    group_by{|entry|entry["granule_class"]}
  end

  def process_entries
    entries.each do |doc_type, doc_representations|
      @doc_data[:document_categories] << {
        name: document_type_names.fetch(doc_type, "Unrecognized"),
        documents: process_documents(doc_representations)
      }
    end
  end

  def process_documents(doc_representations)
    hsh = {}
    doc_representations.each do |doc_representation|
      formatted_doc = format_subjects(doc_representation)

      if hsh[subject_1: formatted_doc[:subject_1], subject_2: formatted_doc[:subject_2]]
        hsh[ subject_1: formatted_doc[:subject_1],subject_2:
          formatted_doc[:subject_2] ][:document_numbers] << doc_representation["document_number"]
      else
        hsh[subject_1: formatted_doc[:subject_1], subject_2: formatted_doc[:subject_2]] = formatted_doc
      end

    end
    hsh.values.sort_by{|k,v|[k[:subject_1],k[:subject_2]]}.each {|k,v|k[:document_numbers].sort!}
  end

  def format_subjects(doc_representation)
    if doc_representation["subject_1"].blank?
      {
        subject_1: doc_representation["subject_2"],
        document_numbers: [doc_representation["document_number"] ]
      }
    else
      {
        subject_1: doc_representation["subject_1"],
        subject_2: doc_representation["subject_2"],
        document_numbers: [doc_representation["document_number"] ]
      }
    end
  end

  def process_see_also
    doc_data[:see_also] = agency.children.map do |child_agency|
      {
        name: child_agency.name,
        slug: child_agency.slug
      }
    end if agency.children.present?
  end

  def ordered_json
    ordered_doc_data = {
      name: agency.try(:name),
      slug: agency.try(:slug),
      url: agency.try(:url),
      document_categories: []
    }

    document_type_names.each do |granule_class, formal_name|
      doc_category_data = doc_data[:document_categories].find{|cat|cat[:name] == formal_name}
      ordered_doc_data[:document_categories] <<
        doc_category_data unless doc_category_data.nil?
    end

    ordered_doc_data[:document_categories].each do |category|
      category[:documents].each { |doc| doc.delete("subject_2") if doc["subject_2"].blank? }
    end

    ordered_doc_data
  end

  def save(document_data)
    FileUtils.mkdir_p(path_manager.index_json_dir)

    File.open json_index_path, 'w' do |f|
      f.write(document_data.to_json)
    end
  end

  def document_type_names
    {
      "RULE" => "Rules",
      "PRORULE" => "Proposed Rules",
      "PRESDOCU" => "Presidential Documents",
      "NOTICE" => "Notices",
      "CORRECT" => "Corrections",
      "SUNSHINE" => "Sunshines",
      "UNKNOWN" => "Unknown"
    }
  end

  def any_documents?
    if entries.present?
      true
    else
      false
    end
  end


  private

  def json_index_path
    "#{path_manager.index_json_dir}#{agency.slug}.json"
  end

end
