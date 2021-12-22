require 'ostruct'

class TableOfContentsTransformer
  extend Memoist
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

      unrecognized_agencies.each do |agency_hsh|
        hsh[:agencies] << agency_hsh
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
          name: agency.name,
          slug: agency.slug,
          see_also: (process_see_also(agency) if agency.children.present?),
          document_categories: process_document_categories(agency)
        }.reject{|key,val| val.nil? }

        agencies_with_metadata[:agencies] << agency_hash
      end
    end
    agencies_with_metadata
  end


  def lookup_agency(text)
    agency_name = AgencyName.find_by_name(text.strip)

    unless agency_name
      Rails.logger.warn("Agency name in ToC but no record found: #{text.strip} for #{date}")
      Honeybadger.notify(**{
        :error_message   => "Agency name in ToC but no record found",
        :parameters    => {
          :agency_name => text.strip,
          :date => date
        }
      })
    end

    agency_name.try(:agency)
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


  private

  def unrecognized_agencies
    agencies_with_metadata = []

    entries_by_unrecognized_agency_name.each do |name, entries|
      if name == IDENTIFIER_FOR_AGENCIES_WITHOUT_AGENCY_NAMES
        next
      end

      agency_representation = create_agency_representation(name)
      agencies_with_metadata << build_agency_hash(
        agency_representation.name,
        agency_representation.slug,
        entries
      )
    end

    entries_without_agency_names = entries_by_unrecognized_agency_name[IDENTIFIER_FOR_AGENCIES_WITHOUT_AGENCY_NAMES]
    if entries_without_agency_names.present?
      agencies_with_metadata << build_agency_hash(
        'Other Documents',
        'other-documents',
        entries_without_agency_names
      )
    end

    agencies_with_metadata
  end

  #NOTE: This is an arbitrary identifier selected for representing entries with no associated agency names
  IDENTIFIER_FOR_AGENCIES_WITHOUT_AGENCY_NAMES = 'no_agency_names'
  def entries_by_unrecognized_agency_name
    entries_without_agencies.each_with_object(Hash.new { |h, k| h[k] = [] }) do |entry, hsh|
      if entry.agency_names.present?
        entry.agency_names.each do |agency_name|
          hsh[agency_name.name] << entry
        end
      else
        hsh[IDENTIFIER_FOR_AGENCIES_WITHOUT_AGENCY_NAMES] << entry
      end
    end
  end
  memoize :entries_by_unrecognized_agency_name

  def build_agency_hash(name, slug, entries)
    {
      name: name,
      slug: slug,
      document_categories: [
        {
          type: "",
          documents: process_document_without_subject(entries)
        }
      ]
    }
  end

  def create_agency_representation(agency_name)
    lookup_agency(agency_name)

    OpenStruct.new(
      name: agency_name,
      slug: agency_name.downcase.gsub(' ','-').gsub(',',''),
    )
  end

end
