class RegulationsDotGov::BulkModifiedDocumentUpdater
  class NoDocumentFound < StandardError; end

  extend Memoist

  def initialize(days)
    @days = days
  end

  def perform
    current_time = Time.current

    document_collection_attributes.each do |document_attributes|
      document_number = document_attributes['frNumber']
      document_id     = document_attributes['documentId']

      entry = document_number ? Entry.
        order("ORDER BY publication_date DESC").
        find_by_document_number(document_number) : nil

      if entry
        entry.checked_regulationsdotgov_at  = current_time
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
  end

  private

  attr_reader :days

  DOCUMENT_TYPE_IDENTIFIERS = ['PR', 'FR', 'N']
  def document_collection_attributes
    Array.new.tap do |collection|
      DOCUMENT_TYPE_IDENTIFIERS.each do |document_type_identifier|
        client = RegulationsDotGov::Client.new
        response = client.find_updated_documents_within(
          days,
          document_type_identifier
        )
        response['documents'].each do |document_attributes|
          collection << document_attributes
        end
      end
    end
  end
  memoize :document_collection_attributes

end
