class LegacyTableOfContentsTransformer
  attr_accessor :agencies, :toc_hash

  def initialize(date=nil)
    #TODO: Junk constructor code from controller to clean up
    @publication_date = (Date.current - 17.years).to_s(:iso)
    @issue = Issue.completed.find_by_publication_date!(@publication_date)
    toc = TableOfContentsPresenter.new(@issue.entries.scoped(:include => [:agencies, :agency_names]))
    @entries_without_agencies = toc.entries_without_agencies


    @agencies = toc.agencies
    @toc_hash = {agencies: [] }
  end

  def process
    @agencies.each do |agency|
      agency_hash = {
        name: agency.name,
        slug: agency.slug,
        url: nil, #TODO
        see_also: (process_see_also(agency) if agency.children.present?),
        document_categories: process_document_categories(agency)
      }.reject{|k,v| v.nil? }

      toc_hash[:agencies] << agency_hash
    end
    toc_hash
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
        documents << process_documents_without_subject(entries_by_toc_subject)
      else
        documents << process_document_with_subject(entries_by_toc_subject)
      end

    end
    documents
  end

  def process_document_without_subject(entries_by_toc_subject)
    entries_by_toc_subject.map do |entry|
      {
        subject_1: entry.toc_subject,
        subject_2: entry.toc_doc || entry.title,
        document_numbers: entry.document_number
      }
    end
  end

  def process_document_with_subject(entries_by_toc_subject)
  end


end

# presenter=LegacyTableOfContentsTransformer.new; presenter.process


