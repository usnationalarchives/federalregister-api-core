namespace :regs_dot_gov do
  
  desc "Bulk enqueue re-update of all #allow_late_comment for recent RegsDotGovDocument objects"
  task :regulationsdotgov_id => :environment do
    RegsDotGovDocument.
      where(deleted_at: nil).
      where("comment_start_date > ?", Date.current - 6.months).
      pluck(:regulations_dot_gov_document_id).
      each do |regulations_dot_gov_document_id|
        EntryRegulationsDotGovAllowLateCommentImporter.perform_async(
          regulations_dot_gov_document_id,
          Date.new(2100,1,1).to_s(:iso) #eg ensure we re-query the API since this is in the far-flung future
        )
      end
  end

end
