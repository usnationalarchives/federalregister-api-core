class EntryRegulationsDotGovImporter
  extend Memoist
  include CacheUtils
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reg_gov, :retry => 1, retry_in: 120
  sidekiq_throttle_as :reg_gov_api

  def self.resync_regulations_dot_gov_document!(api_doc, existing_doc)
    base_attributes = {
      # allow_late_comments:                     TODO: When reg.gov changes their API, make sure we set this attribute
      comment_end_date:                          api_doc.comment_due_date,
      comment_start_date:                        api_doc.comment_start_date,
      deleted_at:                                nil,
      docket_id:                                 api_doc.docket_id,
      regulations_dot_gov_document_id:           api_doc.document_id,
      federal_register_document_number:          api_doc.federal_register_document_number,
      original_federal_register_document_number: api_doc.federal_register_document_number,
      regulations_dot_gov_object_id:             api_doc.regulations_dot_gov_object_id,
      regulations_dot_gov_open_for_comment:      api_doc.regulations_dot_gov_open_for_comment
    }.tap do |attrs|
      if api_doc.comment_start_date
        begin
          attrs.merge!(comment_count: api_doc.comment_count)
        rescue RegulationsDotGov::V4::Client::NotFoundError
          # NOTE: Some documents (2023-11654, 2023-12012) are open per the API but return a 404 when attempting to fetch the comment count.  eg https://api.regulations.gov/v4/document-comments-received-counts/MARAD_FRDOC_0001-2795?api_key=DEMO_KEY
        end
      end
    end

    if existing_doc
      if existing_doc.federal_register_document_number != api_doc.federal_register_document_number
        # Ensure we retain the original FR doc num
        base_attributes.merge!(original_federal_register_document_number: existing_doc.federal_register_document_number)
      end
      existing_doc.update!(base_attributes)
    else
      RegsDotGovDocument.create!(base_attributes)
     
      if api_doc.docket_id.present?
        docket = RegsDotGovDocket.find_or_initialize_by(
          id:                     api_doc.docket_id,
        )
        if docket.new_record?
          docket.save!
          DocketImporter.new.perform(docket.id) # immediately download docket metadata if new docket
        end
      end
    end
  end

  def perform(document_number, publication_date=nil, reindex=false)
    ActiveRecord::Base.clear_active_connections!
    if publication_date
      @entry = Entry.find_by_document_number_and_publication_date!(
        document_number,
        publication_date
      )
    else
      @entry = Entry.includes(:regs_dot_gov_documents).find_by_document_number!(document_number)
    end
    EntryObserver.disabled = true

    entry.checked_regulationsdotgov_at          = checked_regulationsdotgov_at

    entry.comment_count                         = comment_count
    entry.regulationsdotgov_url                 = regulationsdotgov_url
    entry.regulations_dot_gov_comments_close_on = regulations_dot_gov_comments_close_on
    entry.regulations_dot_gov_document_id       = regulations_dot_gov_document_id

    unless entry.comment_url_override?
      entry.comment_url                         = comment_url
      entry.regulations_dot_gov_docket_id       = regulations_dot_gov_docket_id
    end

    resync_regulations_dot_gov_documents_and_dockets!
    purge_varnish = entry.changed?
    entry.save!

    if reindex
      entry.reindex!
    end

    if purge_varnish
      enqueue_delayed_varnish_purge
    end
  end

  def checked_regulationsdotgov_at
    Time.now
  end

  def comment_count
    begin
      regulationsdotgov_document ? regulationsdotgov_document.try(:comment_count) : entry.comment_count
    rescue RegulationsDotGov::V4::Client::NotFoundError
      # NOTE: Some documents (2023-11654, 2023-12012) are open per the API but return a 404 when attempting to fetch the comment count.  eg https://api.regulations.gov/v4/document-comments-received-counts/MARAD_FRDOC_0001-2795?api_key=DEMO_KEY    
    end
  end

  def regulations_dot_gov_document_id
    regulationsdotgov_document ? regulationsdotgov_document.try(:document_id) : entry.regulations_dot_gov_document_id
  end

  def regulationsdotgov_url
    regulationsdotgov_document ? regulationsdotgov_document.try(:url) : entry.regulationsdotgov_url
  end

  def comment_url
    regulationsdotgov_document ? regulationsdotgov_document.try(:comment_url) : entry.comment_url
  end

  def regulations_dot_gov_comments_close_on
    regulationsdotgov_document ? regulationsdotgov_document.try(:comment_due_date) : entry.regulations_dot_gov_comments_close_on
  end

  def regulations_dot_gov_docket_id
    regulationsdotgov_document ? regulationsdotgov_document.try(:docket_id) : entry.regulations_dot_gov_docket_id
  end

  private

  attr_reader :entry

  def resync_regulations_dot_gov_documents_and_dockets!
    existing_docs = entry.regs_dot_gov_documents

    ApplicationModel.transaction do
      # Mark existing regs.gov docs no longer returned in API as deletions
      doc_ids = (regulations_dot_gov_documents.map(&:regulations_dot_gov_document_id))
      existing_docs.
        select{|x| doc_ids.exclude? x.regulations_dot_gov_document_id }.
        each{|x| x.update!(deleted_at: current_time)}

      # Add or resync other documents
      regulations_dot_gov_documents.each do |api_doc|
        # NOTE: We can't assume the existing doc can only be associated with the same FR document
        existing_doc = RegsDotGovDocument.find_by(
          regulations_dot_gov_document_id: api_doc.regulations_dot_gov_document_id,
          deleted_at:                      nil
        )
        self.class.resync_regulations_dot_gov_document!(api_doc, existing_doc)
      end

    end
  end

  def current_time
    Time.current
  end
  memoize :current_time

  def enqueue_delayed_varnish_purge
    # NOTE: We're enqueuing on a delay to avoid an ES/Varnish race condition where varnish caches the old page before the ES index refreshes
    CacheClearer.perform_in(5.seconds, document_paths)
  end
  
  def document_paths
    [
      "/api/v1/documents/#{entry.document_number}*",
      "/documents/#{entry.publication_date.to_s(:ymd)}/#{entry.document_number}/*",
    ]
  end

  def regulations_dot_gov_documents
    RegulationsDotGov::V4::Client.new.find_documents(entry.document_number)
  end
  memoize :regulations_dot_gov_documents

  def regulationsdotgov_document
    RegulationsDotGov::V4::Client.new.find_basic_document(entry.document_number, regulations_dot_gov_documents)
  end
  memoize :regulationsdotgov_document

end
