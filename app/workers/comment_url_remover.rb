class CommentUrlRemover
  include CacheUtils
  include Sidekiq::Worker

  sidekiq_options :queue => :high_priority, :retry => 0

  attr_accessor :entry

  def perform(document_number)
    ActiveRecord::Base.clear_active_connections!
    @entry = Entry.find_by(document_number: document_number)

    entry.comment_url = nil
    entry.save(validate: false)

    purge_cache("^/api/v1/documents/#{entry.document_number}")
    purge_cache("^/documents/#{entry.publication_date.to_s(:ymd)}/#{entry.document_number}")
  end

end
