require 'ostruct'

class LegacyTableOfContentsTransformer
  attr_accessor :agencies, :toc_hash

  def initialize(date = nil)
    publication_date = "Fri, 10 Apr 1998".to_date
    issue = Issue.completed.find_by_publication_date!(publication_date)
    toc = TableOfContentsPresenter.new(issue.entries.scoped(:include => [:agencies, :agency_names]))

    @entries_without_agencies = toc.entries_without_agencies
    @agencies = toc.agencies
    @toc_hash = {agencies: [] }
  end

  def process
    @agencies.each do |agency|
      agency_hash = {
        name: agency.name,
        slug: agency.slug,
        url: url_lookup(agency.name),
        see_also: (process_see_also(agency) if agency.children.present?),
        document_categories: process_document_categories(agency)
      }.reject{|k,v| v.nil? }

      toc_hash[:agencies] << agency_hash
    end
    if @entries_without_agencies.present?
      process_entries_without_agencies(@entries_without_agencies)
    end
    toc_hash
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


  def save_json_file
    process
    save_file("data/", "legacy_test_file_brandon.json", toc_hash.to_json)
  end

  def save_file(path, filename, ruby_object)
    Dir.chdir(path)
    file = File.open(filename, 'w')
    file.puts(ruby_object)
    file.close
    Dir.chdir(Rails.root)
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
        document_numbers: entry.document_number
      }
    end
  end

  def process_document_without_subject(entries_by_toc_subject)
    entries_by_toc_subject.map do |entry|
    {
      subject_1: entry.toc_doc || entry.title,
      document_numbers: entry.document_number
    }
    end
  end


  def process_entries_without_agencies(entries_without_agencies)
    #Need to test this with actual data.
    entries_without_agencies.group_by(&:agency_names).each do |agency_names, entries|
      agency_struct = create_agency_representation_struct
      {
        name: agency_struct.name,
        slug: agency_struct.name,
        url: agency_struct.url,
        document_categories: process_document_without_subject(entries)
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

end

# presenter=LegacyTableOfContentsTransformer.new; presenter.process
# presenter.save_json_file


