class EntryRegulationsDotGovAllowLateCommentImporter
  extend Memoist
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reg_gov, :retry => 0

  def perform(regulations_dot_gov_document_id, last_modified_datetime_string)
    @regulations_dot_gov_document_id = regulations_dot_gov_document_id
    last_modified_datetime = Time.parse(last_modified_datetime_string)

    RegsDotGovDocument.
      where(deleted_at: nil).
      where(regulations_dot_gov_document_id: regulations_dot_gov_document_id).
      includes(:entry).
      each do |regs_dot_gov_document|
        if regs_dot_gov_document.allow_late_comments_updated_at.nil? ||(regs_dot_gov_document.allow_late_comments_updated_at < last_modified_datetime)
          regs_dot_gov_document.update!(
            allow_late_comments:            detailed_document.allow_late_comments,
            allow_late_comments_updated_at: Time.current
          )

          entry = regs_dot_gov_document.entry
          if entry
            entry.reindex!
            entry.clear_varnish!
          end
        end
      end
  end

  private

  attr_reader :regulations_dot_gov_document_id

  def detailed_document
    RegulationsDotGov::V4::Client.new.find_detailed_document(regulations_dot_gov_document_id)
  end
  memoize :detailed_document

end
