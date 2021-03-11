# When a document with an open comment period closes, we need a way of ensuring the comment url is automatically deleted if it has indeed closed per Regulations.gov (so it no longer appears as commentable in FR Web).
class CommentPeriodCloser

  MAX_AGE = 4.months
  def self.perform
    candidate_entries_still_open.each do |entry|
      EntryRegulationsDotGovImporter.perform_async(entry.document_number)
    end
  end

  def self.candidate_entries_still_open
    Entry.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'CommentsClose'").
      where("entries.comment_url IS NOT NULL AND entries.created_at > '#{(Date.current - MAX_AGE).to_s(:iso)}' AND (date is NULL or date < '#{Date.current.to_s(:iso)}')")
  end

end
