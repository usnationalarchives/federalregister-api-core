class EntryRegulationsDotGovImporter
  extend Memoist
  @queue = :reg_gov

  def self.perform(document_number)
    ActiveRecord::Base.clear_active_connections!

    new.perform(document_number)
  end

  def perform(document_number)
    @entry = Entry.find_by_document_number!(document_number)
    EntryObserver.disabled = true

    entry.checked_regulationsdotgov_at          = checked_regulationsdotgov_at

    begin
      entry.comment_count                         = regulationsdotgov_document&.comment_count
      entry.regulationsdotgov_url                 = regulationsdotgov_url
      entry.regulations_dot_gov_comments_close_on = regulations_dot_gov_comments_close_on
      entry.regulations_dot_gov_document_id       = regulationsdotgov_document&.document_id

      unless entry.comment_url_override?
        entry.comment_url                         = comment_url
        entry.regulations_dot_gov_docket_id       = regulations_dot_gov_docket_id
      end

      entry.save!
    rescue RegulationsDotGov::Client::OverRateLimit
      Resque.enqueue(self.class, document_number)
    end
  end

  def checked_regulationsdotgov_at
    Time.now
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
    RegulationsDotGov::Client.new.find_by_document_number(entry.document_number)
  end
  memoize :regulationsdotgov_document

end
