# Testing Regular TOC
# ===========================================
# reload!; presenter=LegacyTableOfContentsTransformer.new("1999-01-06"); presenter.save_standard_doc
# presenter.save_json_file

# Testing Public Inspection
# ===========================================
# reload!; presenter=LegacyTableOfContentsTransformer.new("2011-10-28", {public_inspection: true}); presenter.save_public_inspection_special_filings
# presenter.save_json_file

# Testing All File Formats
# reload!; presenter=LegacyTableOfContentsTransformer.new("2011-10-28", {public_inspection: true}); presenter.save_all_files

require 'ostruct'

class LegacyTableOfContentsTransformer
  attr_reader :date,
    :entries_without_agencies_standard, :agencies_standard,
    :agencies_special_filings, :entries_without_agencies_special_filings,
    :agencies_regular_filings, :entries_without_agencies_regular_filings

  def initialize(date)# Test Date: "1999-01-04"
    @date = date.to_date
  end

  def initialize_standard_toc
    publication_date = date
    issue = Issue.completed.find_by_publication_date!(publication_date)
    toc = TableOfContentsPresenter.new(issue.entries.scoped(:include => [:agencies, :agency_names]))

    @agencies_standard = toc.agencies
    @entries_without_agencies_standard = toc.entries_without_agencies
  end

  def initialize_public_inspection_toc
    issue = PublicInspectionIssue.published.find_by_publication_date!(date)
    special_documents = TableOfContentsPresenter.new(
      issue.public_inspection_documents.special_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
      )
    regular_documents = TableOfContentsPresenter.new(
      issue.public_inspection_documents.regular_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true)
    @agencies_special_filings = special_documents.agencies
    @entries_without_agencies_special_filings = special_documents.entries_without_agencies
    @agencies_regular_filings = regular_documents.agencies
    @entries_without_agencies_regular_filings = regular_documents.entries_without_agencies
  end

  def process_agencies(agencies)
    agencies_with_metadata = {agencies: []}
    agencies.each do |agency|
      if agency
        agency_hash = {
          name: agency.name,
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
      agency_struct = create_agency_representation_struct(agency_names.map(&:name).to_sentence)
      agency_hash = {
        name: agency_struct.name,
        slug: agency_struct.name,
        url: agency_struct.url,
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

  def agency_hash(agencies, entries_without_agencies)
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

  def standard_toc
    initialize_standard_toc
    agency_hash(agencies_standard, entries_without_agencies_standard)
  end

  def special_filings_toc
    initialize_public_inspection_toc
    agency_hash(agencies_special_filings, entries_without_agencies_special_filings)
  end

  def regular_filings_toc
    initialize_public_inspection_toc
    agency_hash(agencies_regular_filings, entries_without_agencies_regular_filings)
  end

  def save_standard_toc
    save_file(standard_toc_output_path, "#{day}.json", standard_toc.to_json)
  end

  def save_public_inspection_special_filings_toc
    save_file(public_inspection_output_path, "special_filing.json", special_filings_toc.to_json)
  end

  def save_public_inspection_regular_filings_toc
    save_file(public_inspection_output_path, "regular_filing.json", regular_filings_toc.to_json)
  end

  def save_all_files
    save_standard_toc
    save_public_inspection_special_filings_toc
    save_public_inspection_regular_filings_toc
  end

  def url_lookup(agency_name)
    agency_struct = create_agency_representation_struct(agency_name)
    agency_struct.url
  end

  def create_agency_representation_struct(agency_name)
    agency = lookup_agency(agency_name)
    if agency
      agency_representation = OpenStruct.new(name: agency_name, slug: agency.slug, url: agency.url)
    else
      agency_representation = OpenStruct.new(name: agency_name, slug: agency_name.downcase.gsub(' ','-'), url: '' )
    end
    agency_representation
  end

  def lookup_agency(agency_name)
    agency_alias = AgencyName.find_by_name(agency_name)
    agency_alias.agency if agency_alias
  end

  def process_see_also(agency)
    agency.children.map { |sub_agency|
      {
        name: sub_agency.name,
        slug: sub_agency.slug
      }
    }
  end

  def process_document_categories(agency)
    agency.entries_by_type_and_toc_subject.map do |type, entries_by_toc_subject|
      {
        name: type.pluralize,
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

  private

  def save_file(path, filename, ruby_object)
    Dir.chdir(path)
    file = File.open(filename, 'w')
    file.puts(ruby_object)
    file.close
    Dir.chdir(Rails.root)
  end

  def standard_toc_output_path
    path = 'data/document_issues/json/' + date.strftime('%Y') +
      '/' + date.strftime('%m') + '/'
    FileUtils.mkdir_p(path)
    path
  end

  def public_inspection_output_path
    path = 'data/public_inspection_issues/json/' + date.strftime('%Y') +
      '/' + date.strftime('%m') + '/' + date.strftime('%d') + '/'
    FileUtils.mkdir_p(path)
    path
  end

  def day
    date.strftime('%d')
  end

end

