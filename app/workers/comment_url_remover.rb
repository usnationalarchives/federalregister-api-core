class CommentUrlRemover
  include CacheUtils

  @queue = :document_updater

  def self.perform(document_number)
    ActiveRecord::Base.clear_active_connections!

    new(document_number).perform
  end

  attr_accessor :entry

  def initialize(document_number)
    @entry = Entry.first(document_number: document_number)
  end

  def perform
    entry.comment_url = nil
    entry.save(validate: false)

    purge_cache("^/api/v1/documents/#{entry.document_number}")
    purge_cache("^/documents/#{entry.publication_date.to_s(:ymd)}/#{entry.document_number}")
  end
end
