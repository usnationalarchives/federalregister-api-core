# When a document with an open comment period closes, we need a way of ensuring the comment url is automatically deleted if it has indeed closed per Regulations.gov (so it no longer appears as commentable in FR Web).
class CommentPeriodCloser

  MAX_AGE = 4.months
  def self.perform
    # Immediately remove comment url from documents we anticipate are closing based on the regulations.gov metadata we've previously imported, but also enqueue a job that re-adds the comment url if the regs.gov API indicates it's still open for comment.  The regulations.gov jobs are throttled (and so it takes time to process through them)--we want to present a better UI by not displaying the document as being open for comment once midnight has elapsed so late-night users don't receive an error message about the document not being open for comment when submission is attempted.
    batch = Sidekiq::Batch.new
    batch.description = "Reimport of regulations.gov metadata for anticipated document closings"
    batch.on(:complete, CachePurger, paths: "/")
    batch.jobs do
      daily_entries_anticipated_for_closing.each do |entry|
        entry.update!(comment_url: nil)
        EntryRegulationsDotGovImporter.perform_async(entry.document_number, nil, true)
      end
      candidate_document_numbers_still_open.each do |doc_number|
        EntryRegulationsDotGovImporter.perform_async(doc_number, nil, true)
      end
    end
  end

  def self.candidate_document_numbers_still_open
    comments_scope = base_scope.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'CommentsClose'").
      where("date is NULL OR date < '#{Date.current.to_s(:iso)}'")

    regs_scope = base_scope.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'RegulationsDotGovCommentsClose'").
      where("date is NULL OR date <= '#{Date.current.to_s(:iso)}'")

    (comments_scope.pluck(:document_number) + regs_scope.pluck(:document_number)).uniq
  end

  private

  def self.base_scope
    Entry.
      where.not(comment_url: nil).
      where("entries.created_at > '#{(Date.current - MAX_AGE).to_s(:iso)}'")
  end

  def self.daily_entries_anticipated_for_closing
    base_scope.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'RegulationsDotGovCommentsClose'").
      where("date = '#{Date.current.to_s(:iso)}'")
  end

end
