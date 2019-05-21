class RegulationsDotGov::RecentlyModifiedDocumentUpdater
  extend Memoist
  include CacheUtils
  
  class NoDocumentFound < StandardError; end

  DOCUMENT_TYPE_IDENTIFIERS = ['PR', 'FR', 'N']
  
  attr_reader :days
  
  def initialize(days)
    @days = days
  end

  def perform
    ActiveRecord::Base.verify_active_connections!
    EntryObserver.disabled = true
    current_time           = Time.current
    expire_cache           = false

    document_collection_attributes.each do |document_attributes|
      document_number = document_attributes['frNumber']
      document_id     = document_attributes['documentId']

      entry = document_number ? Entry.
        order("ORDER BY publication_date DESC").
        find_by_document_number(document_number) : nil

      if entry
        entry.regulations_dot_gov_docket_id = document_attributes['docketId']
        update_docket                       = entry.regulations_dot_gov_docket_id_changed?

        if document_id
          if document_attributes['openForComment'] &&
            DocketImporter.non_participating_agency_ids.exclude?(document_attributes['agencyAcronym'])
            comment_url = "http://www.regulations.gov/#!submitComment;D=#{document_id}"
            entry.comment_url = comment_url
          end

          entry.regulationsdotgov_url = "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
        end

        if entry.changed?
          expire_cache = true
        end
        entry.checked_regulationsdotgov_at  = current_time

        entry.save!

        if update_docket
          Resque.enqueue(DocketImporter, entry.regulations_dot_gov_docket_id)
        end
      else
        Honeybadger.notify(
          :error_class   => NoDocumentFound,
          :error_message => "Regulations Dot Gov noted entry #{document_number} changed within the last #{days} days, but no entry was found.  Document details: #{document_attributes}"
        )
      end
    end

    if expire_cache
      purge_cache("/api/v1/*")
    end
  end

  private

  def document_collection_attributes
    Array.new.tap do |collection|
      DOCUMENT_TYPE_IDENTIFIERS.each do |document_type_identifier|
        client = RegulationsDotGov::Client.new

        documents = client.find_documents_updated_within(
          0,
          document_type_identifier
        )
        binding.pry

        documents.each do |document|
          collection << document.raw_attributes
        end

      end
    end
  end
  memoize :document_collection_attributes

end
