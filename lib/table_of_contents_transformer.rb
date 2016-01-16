require 'ostruct'

class TableOfContentsTransformer
  attr_reader :date, :path_manager

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @path_manager = FileSystemPathManager.new(@date)
  end

  def self.perform(date)
    transformer = new(date)
    transformer.save(transformer.table_of_contents)
  end

  def table_of_contents
    if entries_without_agencies.present?
      hsh = process_agencies(agencies)
      process_entries_without_agencies(entries_without_agencies)[:agencies].each do |agency|
        hsh[:agencies] << agency
      end
      hsh
    else
      process_agencies(agencies)
    end
  end

  def agencies
    toc_presenter.agencies
  end

  def entries_without_agencies
    toc_presenter.entries_without_agencies
  end

  def process_agencies(agencies)
    agencies_with_metadata = {agencies: []}
    agencies.each do |agency|
      if agency
        agency_hash = {
          name: agency.name.downcase.titleize,
          slug: agency.slug,
          url: url_lookup(agency.name),
          see_also: (process_see_also(agency) if agency.children.present?),
          document_categories: process_document_categories(agency)
        }.reject{|key,val| val.nil? }

        agencies_with_metadata[:agencies] << agency_hash
      end
    end
    agencies_with_metadata
  end

  def process_entries_without_agencies(agencies)
    agencies_with_metadata = {agencies: []}
    agencies.group_by(&:agency_names).each do |agency_names, entries|
      agency_stub = create_agency_representation(agency_names.map(&:name).to_sentence)
      agency_hash = {
        name: agency_stub.name.downcase.titleize,
        slug: agency_stub.slug,
        url: agency_stub.url,
        document_categories: [
          {
            name: "",
            documents: process_document_without_subject(entries)
          }
        ]
      }
      agencies_with_metadata[:agencies] << agency_hash
    end
    agencies_with_metadata
  end

  def url_lookup(agency_name)
    create_agency_representation(agency_name).url
  end

  def create_agency_representation(agency_name)
    if agency_name.empty?
      agency_representation = OpenStruct.new(
        name: "Other Documents",
        slug: "other-documents",
        url: ""
      )
    else
      agency_representation = OpenStruct.new(
        name: agency_name,
        slug: agency_name.downcase.gsub(' ','-'),
        url: ''
      )

      agency = lookup_agency(agency_name)
      agency_representation.url = agency.url if agency
    end

    agency_representation
  end

  def lookup_agency(agency_name)
    AgencyName.find_by_name(agency_name).try(:agency)
  end

  def process_see_also(agency)
    agency.children.map do |sub_agency|
      {
        name: sub_agency.name,
        slug: sub_agency.slug
      }
    end
  end

  def process_document_categories(agency)
    agency.entries_by_type_and_toc_subject.map do |type, entries_by_toc_subject|
      {
        type: type,
        documents: process_documents(entries_by_toc_subject)
      }
    end
  end

  def process_documents(entries_by_toc_subject)
    documents=[]
    entries_by_toc_subject.each do |toc_subject, entries_by_toc_subject|
      if toc_subject.present?
        documents << process_document_with_subject(entries_by_toc_subject)
      else
        documents << process_document_without_subject(entries_by_toc_subject)
      end
    end

    documents.flatten
  end

  def process_document_with_subject(entries_by_toc_subject)
    entries_by_toc_subject.map do |entry|
      {
        subject_1: entry.toc_subject,
        subject_2: entry.toc_doc || entry.title,
        document_numbers: [entry.document_number]
      }
    end
  end

  def process_document_without_subject(entries_by_toc_subject)
    entries_by_toc_subject.map do |entry|
    {
      subject_1: entry.toc_doc || entry.title,
      document_numbers: [entry.document_number]
    }
    end
  end

  def save(table_of_contents)
    FileUtils.mkdir_p(json_toc_dir)

    File.open json_path, 'w' do |f|
      f.write(table_of_contents.to_json)
    end
  end
end

require_dependency('./table_of_contents_transformer/document_issue')
require_dependency('./table_of_contents_transformer/public_inspection')
require_dependency('./table_of_contents_transformer/public_inspection/regular_filing')
require_dependency('./table_of_contents_transformer/public_inspection/special_filing')
