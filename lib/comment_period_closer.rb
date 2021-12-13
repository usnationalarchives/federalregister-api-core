# When a document with an open comment period closes, we need a way of ensuring the comment url is automatically deleted if it has indeed closed per Regulations.gov (so it no longer appears as commentable in FR Web).
class CommentPeriodCloser

  MAX_AGE = 4.months
  def self.perform
    candidate_document_numbers_still_open.each do |doc_number|
      EntryRegulationsDotGovImporter.perform_async(doc_number, nil, true)
    end
  end

  def self.candidate_document_numbers_still_open
    base_scope = Entry.
      where.not(comment_url: nil).
      where("entries.created_at > '#{(Date.current - MAX_AGE).to_s(:iso)}'")

    comments_scope = base_scope.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'CommentsClose'").
      where("date is NULL OR date < '#{Date.current.to_s(:iso)}'")

    regs_scope = base_scope.
      joins("LEFT JOIN events ON entries.id = events.entry_id AND event_type = 'RegulationsDotGovCommentsClose'").
      where("date is NULL OR date <= '#{Date.current.to_s(:iso)}'")

    (comments_scope.pluck(:document_number) + regs_scope.pluck(:document_number)).uniq
  end

end
