class RegulationsDotGov::CommentPublicationNotifier
  def perform
    comments.find_each do |comment|
      comment.checked_comment_publication_at = Time.current

      documents = client.find_documents(:s => comment.comment_tracking_number, :dct => "PS")

      if documents.size > 0
        comment.comment_document_number = documents.first.document_id
        CommentMailer.comment_posting_notification(comment.user, comment).deliver
      end

      comment.save(:validate => false)
    end
  end

  def comments
    Comment.
      where("comments.user_id IS NOT NULL").
      where(:comment_publication_notification => true).
      where(:created_at => Time.current - 3.months .. Time.current).
      where(:comment_document_number => nil).
      where(:agency_participating => true)
  end

  def client
    @client ||= RegulationsDotGov::Client.new
  end
end
