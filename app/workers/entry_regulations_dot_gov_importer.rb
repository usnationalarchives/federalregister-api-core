class EntryRegulationsDotGovImporter
  extend Memoist
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reg_gov
  sidekiq_throttle_as :reg_gov_api

  def perform(document_number)
    ActiveRecord::Base.clear_active_connections!
    @entry = Entry.find_by_document_number!(document_number)
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

    entry.save!
  end

  def checked_regulationsdotgov_at
    Time.now
  end

  def comment_count
    regulationsdotgov_document ? regulationsdotgov_document.try(:comment_count) : entry.comment_count
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

  def regulationsdotgov_document
    if SETTINGS['regulations_dot_gov']['use_v4_api']
      RegulationsDotGov::V4::Client.new.find_basic_document(entry.document_number)
    else
      RegulationsDotGov::Client.new.find_by_document_number(entry.document_number)
    end
  end
  memoize :regulationsdotgov_document

end
