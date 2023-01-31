require 'csv'

class DocketImporter
  extend Memoist
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reg_gov_dockets, :retry => 0
  sidekiq_throttle_as :reg_gov_api

  NON_PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_non_participating_agencies.csv'

  def self.non_participating_agency_ids
    @non_participating_agency_ids ||= CSV.new(
      File.open(NON_PARTICIPATING_AGENCIES_FILE),
      :headers => :first_row,
      :skip_blanks => true
    ).map do |row|
      row["Agency ID"]
    end
  end

  PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_participating_agencies.csv'

  def self.participating_agency_ids
    @participating_agency_ids ||= CSV.new(
      File.open(PARTICIPATING_AGENCIES_FILE),
      :headers => :first_row,
      :skip_blanks => true
    ).map do |row|
      row["Acronym"]
    end
  end

  TITLE_CHARACTER_LIMIT = 1000
  def perform(docket_number, check_participating=true, reindex=false)
    ActiveRecord::Base.clear_active_connections!

    return if check_participating && non_participating_agency?(docket_number)

    client = regulations_dot_gov_client
    api_docket = client.find_docket(docket_number)

    return unless api_docket

    EntryObserver.disabled = true

    docket = RegsDotGovDocket.find_or_initialize_by(id: docket_number)
    docket.title = api_docket.title.truncate(TITLE_CHARACTER_LIMIT)
    docket.agency_id = api_docket.agency_id
    docket.comments_count = api_docket.comments_count
    docket.docket_documents_count = api_docket.supporting_documents_count
    docket.regulation_id_number = api_docket.regulation_id_number

    if !docket.default_docket?
      docket.regs_dot_gov_supporting_documents = api_docket.supporting_documents.map do |api_doc|
        doc = RegsDotGovSupportingDocument.find_or_initialize_by(id: api_doc.document_id)
        doc.title = api_doc.title.truncate(TITLE_CHARACTER_LIMIT)
        doc.metadata = api_doc.metadata
        doc
      end
    end

    docket.save

    if reindex
      reindex_associated_entries!(docket)
    end
  end

  private

  def reindex_associated_entries!(docket)
    Entry.
      where(id: docket.entries.pluck(:id).uniq).
      includes(:regs_dot_gov_documents).
      find_in_batches(batch_size: 10000) do |entry_batch|
        Entry.bulk_update(entry_batch, refresh: false, attribute: dockets_attribute)
      end
  end

  def dockets_attribute
    EntrySerializer.attributes_to_serialize.find{|k,v| k == :dockets}.last
  end
  memoize :dockets_attribute

  def regulations_dot_gov_client
    RegulationsDotGov::V4::Client.new
  end

  def non_participating_agency?(docket_number)
    self.class.non_participating_agency_ids.any? do |str|
      docket_number.start_with? "#{str}-", "#{str}_"
    end
  end
end
