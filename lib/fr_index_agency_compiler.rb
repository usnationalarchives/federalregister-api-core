class FrIndexAgencyCompiler
  attr_reader :doc_data, :agency, :year, :path_manager, :document_type_names

  DEFAULT_SUBJECT_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_SUBJECT_SQL
  SUBJECT_SQL = FrIndexPresenter::EntryPresenter::SUBJECT_SQL
  DEFAULT_DOC_SQL = FrIndexPresenter::EntryPresenter::DEFAULT_DOC_SQL
  DOC_SQL = FrIndexPresenter::EntryPresenter::DOC_SQL

  def initialize(year, agency_id)
    @agency = Agency.find(agency_id)
    @year = year.to_i
    @path_manager = FileSystemPathManager.new("#{year}-01-01")
    @document_type_names = Entry::ENTRY_TYPES
    @doc_data = {
      name: agency.try(:name),
      slug: agency.try(:slug),
      url: agency.try(:url),
      document_categories: []
    }
  end

  def self.perform(year)
    Agency.all.each do |agency|
      process_agency_with_docs(year, agency.id)
    end
    clear_cache(year)
  end

  def self.clear_cache(year)
    path_manager = FileSystemPathManager.new("#{year}-01-01")
    cached_path = path_manager.index_json_dir.gsub(path_manager.data_file_path, '')
    CacheUtils.purge_cache("#{cached_path}/*")
  end

  def self.process_agency_with_docs(year, agency_id)
    agency_representation = new(year, agency_id)
    if agency_representation.any_documents?
      puts "Processing Agency #{agency_id} for #{year}."
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
      Entry.
        select("entries.id, MAX(entries.document_number) AS document_number, MAX(entries.granule_class) AS granule_class, #{SUBJECT_SQL} AS subject_1, #{DOC_SQL} AS subject_2").
        joins(:agencies, :public_inspection_document).
        where(agencies: agency.id).
        where("entries.publication_date >= ?", "#{year}-01-01").
        where("entries.publication_date <= ?", "#{year}-12-31").
        group("entries.id").
        to_sql
    ]). 
    group_by{|entry|entry["granule_class"]}
  end 

  def process_entries
    entries.each do |doc_type, doc_representations|
      @doc_data[:document_categories] << {
        type: document_type_names[doc_type],
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
    # force nils to be sorted first by treating them as 'AAAA'
    hsh.values.sort_by{|k,v|[k[:subject_1],k[:subject_2] || 'AAAA']}.each {|k,v|k[:document_numbers].sort!}
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
      pdf: pdf_metadata,
      document_categories: [],
    }

    document_type_names.each do |granule_class, formal_name|
      doc_category_data = doc_data[:document_categories].find{|cat|cat[:type] == formal_name}
      ordered_doc_data[:document_categories] <<
        doc_category_data unless doc_category_data.nil?
    end

    ordered_doc_data[:document_categories].each do |category|
      category[:documents].each { |doc| doc.delete("subject_2") if doc["subject_2"].blank? }
    end

    ordered_doc_data
  end

  def save(document_data)
    FileUtils.mkdir_p(path_manager.index_json_dir, mode: 0755)

    File.open(path_manager.index_agency_json_path(agency), 'w') do |f|
      f.write(document_data.to_json)
    end
  end

  def any_documents?
    if entries.present?
      true
    else
      false
    end
  end

  def pdf_metadata
    last_published_date = FrIndexAgencyStatus.
      scoped(
        order: "last_published DESC",
        conditions: ["last_published IS NOT NULL and YEAR = ?", year],
      ).
      first.
      try(:last_published)

    if last_published_date
      @doc_data[:pdf] = {
        url: "#{Settings.app.canonical_url}#{path_manager.index_agency_pdf_path(agency, last_published_date).gsub(path_manager.send(:data_file_path),'')}",
        approval_date: last_published_date.to_s(:iso),
      }
    else
      @doc_data[:pdf] = {
        url: nil,
        approval_date: nil,
      }
    end
  end
end
